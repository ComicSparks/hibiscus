use std::collections::HashMap;
use std::sync::OnceLock;
use std::time::Duration;

use anyhow::anyhow;
use base64::Engine;
use futures_util::future::BoxFuture;
use once_cell::sync::OnceCell;
use opentelemetry::global;
use opentelemetry::trace::{SpanKind, Tracer};
use opentelemetry::KeyValue;
use opentelemetry_sdk::export::trace::{ExportResult, SpanData};
use opentelemetry_sdk::trace::{RandomIdGenerator, Sampler};
use opentelemetry_sdk::Resource;
use prost::Message;
use tokio::sync::Mutex;

use crate::core::storage;

// ============ OTLP Endpoint ============

const OTLP_URL_KEY: &str = "otlp.url";
const LAST_USERNAME_KEY: &str = "user.last_username";

fn load_otlp_url() -> Option<String> {
    match storage::get_setting(OTLP_URL_KEY) {
        Ok(Some(v)) => {
            let s = v.trim().to_string();
            if s.is_empty() {
                None
            } else {
                Some(s)
            }
        }
        _ => None,
    }
}

// ============ install_id & resource ============

const INSTALL_ID_KEY: &str = "install_id";
static INSTALL_ID: OnceCell<String> = OnceCell::new();
static GLOBAL_RESOURCE: OnceCell<Resource> = OnceCell::new();

fn get_resource() -> &'static Resource {
    GLOBAL_RESOURCE
        .get()
        .expect("GLOBAL_RESOURCE not initialized")
}

async fn ensure_install_id() -> Option<String> {
    if let Some(id) = INSTALL_ID.get() {
        return Some(id.clone());
    }

    let in_db = storage::get_setting(INSTALL_ID_KEY).unwrap_or_default();
    if let Some(id) = in_db {
        if !id.is_empty() {
            let _ = INSTALL_ID.set(id.clone());
            return Some(id);
        }
    }

    let generated = uuid::Uuid::new_v4().to_string();
    if storage::save_setting(INSTALL_ID_KEY, &generated).is_ok() {
        let _ = INSTALL_ID.set(generated.clone());
        return Some(generated);
    }
    None
}

fn init_resource(install_id: Option<&str>) -> Resource {
    let mut attrs = vec![
        KeyValue::new("service.name", "hibiscus"),
        KeyValue::new("service.version", env!("CARGO_PKG_VERSION")),
        KeyValue::new("deployment.environment", "production"),
    ];
    if let Some(id) = install_id {
        attrs.push(KeyValue::new(INSTALL_ID_KEY, id.to_string()));
    }
    Resource::new(attrs)
}

// ============ dynamic span attributes ============

static DYNAMIC_SPAN_ATTRS: OnceCell<Mutex<HashMap<String, String>>> = OnceCell::new();

fn dynamic_attrs_store() -> &'static Mutex<HashMap<String, String>> {
    DYNAMIC_SPAN_ATTRS.get_or_init(|| Mutex::new(HashMap::new()))
}

pub async fn update_span_attribute(key: &str, value: Option<String>) {
    let mut guard = dynamic_attrs_store().lock().await;
    match value {
        Some(val) => {
            guard.insert(key.to_string(), val);
        }
        None => {
            guard.remove(key);
        }
    };
}

async fn get_span_attributes() -> Vec<KeyValue> {
    let guard = dynamic_attrs_store().lock().await;
    guard
        .iter()
        .map(|(k, v)| KeyValue::new(k.clone(), v.clone()))
        .collect()
}

// ============ exporter: persist spans as protobuf(base64) ============

#[derive(Debug)]
pub struct PersistentSpanExporter;

impl PersistentSpanExporter {
    pub fn new() -> Self {
        Self
    }
}

fn spans_to_protobuf_base64(spans: &[SpanData], resource: &Resource) -> Option<String> {
    use opentelemetry_proto::tonic::collector::trace::v1::ExportTraceServiceRequest;
    use opentelemetry_proto::tonic::common::v1::{any_value, AnyValue, KeyValue as ProtoKeyValue};
    use opentelemetry_proto::tonic::resource::v1::Resource as ProtoResource;
    use opentelemetry_proto::tonic::trace::v1::{ResourceSpans, ScopeSpans, Span, Status};

    if spans.is_empty() {
        return None;
    }

    let resource_attrs: Vec<ProtoKeyValue> = resource
        .iter()
        .map(|(k, v)| ProtoKeyValue {
            key: k.to_string(),
            value: Some(AnyValue {
                value: Some(any_value::Value::StringValue(format!("{}", v))),
            }),
        })
        .collect();

    let proto_spans: Vec<Span> = spans
        .iter()
        .map(|span| {
            let attributes: Vec<ProtoKeyValue> = span
                .attributes
                .iter()
                .map(|kv| ProtoKeyValue {
                    key: kv.key.to_string(),
                    value: Some(AnyValue {
                        value: Some(any_value::Value::StringValue(format!("{}", kv.value))),
                    }),
                })
                .collect();

            let status = match &span.status {
                opentelemetry::trace::Status::Unset => Status {
                    code: 0,
                    message: String::new(),
                },
                opentelemetry::trace::Status::Ok => Status {
                    code: 1,
                    message: String::new(),
                },
                opentelemetry::trace::Status::Error { description } => Status {
                    code: 2,
                    message: description.to_string(),
                },
            };

            let kind = match span.span_kind {
                SpanKind::Internal => 1,
                SpanKind::Server => 2,
                SpanKind::Client => 3,
                SpanKind::Producer => 4,
                SpanKind::Consumer => 5,
            };

            let parent_span_id = if span.parent_span_id.to_string() == "0000000000000000" {
                vec![]
            } else {
                span.parent_span_id.to_bytes().to_vec()
            };

            Span {
                trace_id: span.span_context.trace_id().to_bytes().to_vec(),
                span_id: span.span_context.span_id().to_bytes().to_vec(),
                trace_state: String::new(),
                parent_span_id,
                flags: 0,
                name: span.name.to_string(),
                kind,
                start_time_unix_nano: span
                    .start_time
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap()
                    .as_nanos() as u64,
                end_time_unix_nano: span
                    .end_time
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap()
                    .as_nanos() as u64,
                attributes,
                dropped_attributes_count: 0,
                events: vec![],
                dropped_events_count: 0,
                links: vec![],
                dropped_links_count: 0,
                status: Some(status),
            }
        })
        .collect();

    let scope_spans = ScopeSpans {
        scope: Some(
            opentelemetry_proto::tonic::common::v1::InstrumentationScope {
                name: "hibiscus".to_string(),
                version: env!("CARGO_PKG_VERSION").to_string(),
                attributes: vec![],
                dropped_attributes_count: 0,
            },
        ),
        spans: proto_spans,
        schema_url: String::new(),
    };

    let resource_spans = ResourceSpans {
        resource: Some(ProtoResource {
            attributes: resource_attrs,
            dropped_attributes_count: 0,
        }),
        scope_spans: vec![scope_spans],
        schema_url: String::new(),
    };

    let request = ExportTraceServiceRequest {
        resource_spans: vec![resource_spans],
    };

    let mut buf = Vec::new();
    if request.encode(&mut buf).is_ok() {
        Some(base64::engine::general_purpose::STANDARD.encode(&buf))
    } else {
        None
    }
}

impl opentelemetry_sdk::export::trace::SpanExporter for PersistentSpanExporter {
    fn export(&mut self, batch: Vec<SpanData>) -> BoxFuture<'static, ExportResult> {
        Box::pin(async move {
            if let Some(protobuf_base64) = spans_to_protobuf_base64(&batch, get_resource()) {
                let _ = storage::enqueue_telemetry(&protobuf_base64);
            }
            Ok(())
        })
    }

    fn shutdown(&mut self) {}
}

async fn init_tracer_with_exporter(
    exporter: PersistentSpanExporter,
    resource: Resource,
) -> Result<(), opentelemetry::trace::TraceError> {
    let tracer_provider = opentelemetry_sdk::trace::TracerProvider::builder()
        .with_batch_exporter(exporter, opentelemetry_sdk::runtime::Tokio)
        .with_sampler(Sampler::AlwaysOn)
        .with_id_generator(RandomIdGenerator::default())
        .with_resource(resource)
        .build();
    global::set_tracer_provider(tracer_provider);
    Ok(())
}

// ============ background reporter ============

const REPORT_INTERVAL_SECS: u64 = 30;
const BATCH_SIZE: u32 = 50;
const MAX_RETRY_COUNT: i32 = 10;
const VACUUM_THRESHOLD: u64 = 100;
const STARTUP_KEEP_LATEST: i64 = 500;

async fn send_protobuf_to_server(
    client: &reqwest::Client,
    url: &str,
    protobuf_base64: &str,
) -> anyhow::Result<()> {
    let protobuf_bytes = base64::engine::general_purpose::STANDARD.decode(protobuf_base64)?;

    let response = client
        .post(url)
        .header("Content-Type", "application/x-protobuf")
        .body(protobuf_bytes)
        .timeout(Duration::from_secs(10))
        .send()
        .await?;

    if response.status().is_success() {
        Ok(())
    } else {
        let status = response.status();
        let body = response.text().await.unwrap_or_default();
        Err(anyhow!("Server returned {}: {}", status, body))
    }
}

async fn background_reporter() {
    let http_client = reqwest::Client::builder()
        .timeout(Duration::from_secs(10))
        .build()
        .expect("Failed to create HTTP client");

    let mut success_count: u64 = 0;
    let mut consecutive_failures: u32 = 0;

    loop {
        let wait_secs = if consecutive_failures > 0 {
            std::cmp::min(
                REPORT_INTERVAL_SECS * (2_u64.pow(consecutive_failures - 1)),
                300,
            )
        } else {
            REPORT_INTERVAL_SECS
        };
        tokio::time::sleep(Duration::from_secs(wait_secs)).await;

        let count = match storage::telemetry_count() {
            Ok(c) => c,
            Err(e) => {
                tracing::debug!("[OTLP] Failed to get queue count: {e:?}");
                continue;
            }
        };
        if count == 0 {
            consecutive_failures = 0;
            continue;
        }

        let Some(url) = load_otlp_url() else {
            // OTLP endpoint not configured yet; skip reporting.
            continue;
        };

        let records = match storage::dequeue_telemetry_batch(BATCH_SIZE) {
            Ok(r) => r,
            Err(e) => {
                tracing::debug!("[OTLP] Failed to dequeue batch: {e:?}");
                consecutive_failures = consecutive_failures.saturating_add(1);
                continue;
            }
        };
        if records.is_empty() {
            continue;
        }

        let mut success_ids: Vec<i64> = Vec::new();
        let mut failed_ids: Vec<i64> = Vec::new();

        for record in &records {
            match send_protobuf_to_server(&http_client, &url, &record.payload_base64).await {
                Ok(_) => success_ids.push(record.id),
                Err(e) => {
                    tracing::debug!("[OTLP] Failed to send record {}: {e:?}", record.id);
                    failed_ids.push(record.id);
                }
            }
        }

        if !success_ids.is_empty() {
            let deleted_count = success_ids.len() as u64;
            if let Err(e) = storage::delete_telemetry_by_ids(&success_ids) {
                tracing::debug!("[OTLP] Failed to delete success records: {e:?}");
            } else {
                success_count += deleted_count;
                consecutive_failures = 0;
            }
        }

        if !failed_ids.is_empty() {
            if let Err(e) = storage::increment_telemetry_retry_count(&failed_ids) {
                tracing::debug!("[OTLP] Failed to increment retry count: {e:?}");
            }
            consecutive_failures = consecutive_failures.saturating_add(1);
        }

        if success_count >= VACUUM_THRESHOLD {
            let _ = storage::vacuum();
            success_count = 0;
        }

        let _ = storage::delete_telemetry_exceeded_retry(MAX_RETRY_COUNT);
    }
}

// ============ public API ============

static INIT_ONCE: OnceLock<()> = OnceLock::new();

pub async fn init() -> anyhow::Result<()> {
    if INIT_ONCE.set(()).is_err() {
        return Ok(());
    }

    let install_id = ensure_install_id().await;
    let resource = init_resource(install_id.as_deref());
    let _ = GLOBAL_RESOURCE.set(resource.clone());

    if let Ok(Some(last)) = storage::get_setting(LAST_USERNAME_KEY) {
        let s = last.trim().to_string();
        if !s.is_empty() {
            update_span_attribute("user.account", Some(s)).await;
        }
    }

    let _ = storage::cleanup_telemetry_keep_latest(STARTUP_KEEP_LATEST);

    let exporter = PersistentSpanExporter::new();
    init_tracer_with_exporter(exporter, resource)
        .await
        .map_err(|e| anyhow!("Failed to init tracer: {e:?}"))?;

    tokio::spawn(background_reporter());
    record_event("app", "app.start", vec![]).await;
    tracing::info!("[OTLP] Telemetry module initialized");
    Ok(())
}

pub fn tracer(name: &'static str) -> opentelemetry::global::BoxedTracer {
    global::tracer(name)
}

pub async fn record_event(tracer_name: &'static str, event_name: &str, attrs: Vec<KeyValue>) {
    use opentelemetry::trace::Span;

    let tracer = tracer(tracer_name);
    let dynamic_attrs = get_span_attributes().await;

    let mut span = tracer
        .span_builder(event_name.to_string())
        .with_kind(SpanKind::Internal)
        .start(&tracer);

    let mut attributes = Vec::new();
    attributes.extend(dynamic_attrs);
    attributes.extend(attrs);
    span.add_event(event_name.to_string(), attributes);
    span.end();
}
