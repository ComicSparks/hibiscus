import 'dart:convert';
import 'dart:io';

import 'package:hibiscus/src/services/app_logger.dart';
import 'package:hibiscus/src/services/rust_kv_store.dart';
import 'package:signals/signals_flutter.dart';

const String _remoteConfigBodyKey = 'remote_config.body_json';
const String _remoteConfigLastFetchMsKey = 'remote_config.last_fetch_ms';
const String _otlpUrlKey = 'otlp.url';

const Duration _defaultCacheTtl = Duration(minutes: 10);
const Duration _maxRemoteConfigStale = Duration(hours: 48);

const String _configOwnerKey = 'remote_config.owner';
const String _configRepoKey = 'remote_config.repo';
const String _configRepoNameKey = 'remote_config.repo_name';
const String _configTagKey = 'remote_config.tag';

const String repoOwner = String.fromEnvironment(
  'REPO_OWNER',
  defaultValue: 'ComicSparks',
);
const String repoName = String.fromEnvironment(
  'REPO_NAME',
  defaultValue: 'hibiscus',
);

const String hibiscusConfigReleaseUrl =
    'https://api.github.com/repos/$repoOwner/glxx/releases/tags/$repoName-config';

final remoteConfigSignal = signal<RemoteConfig?>(null);

class RemoteConfig {
  final String? otlpUrl;
  final String? repo;
  final String? recommendUrl;
  final Map<String, String> links;

  const RemoteConfig({
    required this.otlpUrl,
    required this.repo,
    required this.recommendUrl,
    required this.links,
  });

  factory RemoteConfig.fromConfigBodyJson(Map<String, dynamic> bodyJson) {
    final otlpHost = (bodyJson['otlp'] as String?)?.trim();
    final otlpUrl = (otlpHost == null || otlpHost.isEmpty)
        ? null
        : 'https://$otlpHost/v1/traces';

    final repo =
        (bodyJson['repo'] as String?)?.trim() ??
        (bodyJson['update_repo'] as String?)?.trim() ??
        (bodyJson['repository'] as String?)?.trim();

    final recommendUrl =
        (bodyJson['recommend'] as String?)?.trim() ??
        (bodyJson['recommend_url'] as String?)?.trim() ??
        (bodyJson['recommendations'] as String?)?.trim();

    final links = <String, String>{};
    final rawLinks = bodyJson['links'];
    if (rawLinks is Map) {
      for (final entry in rawLinks.entries) {
        final key = entry.key?.toString();
        final value = entry.value?.toString();
        if (key == null || key.isEmpty) continue;
        if (value == null || value.trim().isEmpty) continue;
        links[key] = value.trim();
      }
    }

    return RemoteConfig(
      otlpUrl: otlpUrl,
      repo: repo,
      recommendUrl: recommendUrl,
      links: links,
    );
  }
}

Future<RemoteConfig?> loadCachedRemoteConfig() async {
  final body = (await RustKvStore.getString(_remoteConfigBodyKey))?.trim() ?? '';
  if (body.isEmpty) return null;
  try {
    final json = jsonDecode(body);
    if (json is! Map<String, dynamic>) return null;
    final cfg = RemoteConfig.fromConfigBodyJson(json);
    await _syncOtlpUrl(cfg.otlpUrl);
    return cfg;
  } catch (e) {
    return null;
  }
}

Future<RemoteConfig?> getRemoteConfig({
  bool forceRefresh = false,
  Duration cacheTtl = _defaultCacheTtl,
  Duration timeout = const Duration(seconds: 8),
}) async {
  final nowMs = DateTime.now().millisecondsSinceEpoch;
  final lastMs = int.tryParse(
        (await RustKvStore.getString(_remoteConfigLastFetchMsKey)) ?? '',
      ) ??
      0;

  if (!forceRefresh && lastMs > 0 && nowMs - lastMs < cacheTtl.inMilliseconds) {
    final cached = await loadCachedRemoteConfig();
    if (cached != null) {
      remoteConfigSignal.value = cached;
      return cached;
    }
  }

  final fetched = await _fetchRemoteConfig(timeout: timeout);
  if (fetched != null) {
    remoteConfigSignal.value = fetched;
    return fetched;
  }

  return _handleFetchFailure(lastMs, nowMs);
}

Future<void> _syncOtlpUrl(String? otlpUrl) async {
  await RustKvStore.setString(_otlpUrlKey, (otlpUrl ?? '').trim());
}

Future<Uri> _getConfigReleaseUri() async {
  var owner = (await RustKvStore.getString(_configOwnerKey))?.trim() ?? '';
  var repo = (await RustKvStore.getString(_configRepoKey))?.trim() ?? '';
  var repoNameValue =
      (await RustKvStore.getString(_configRepoNameKey))?.trim() ?? '';
  var tag = (await RustKvStore.getString(_configTagKey))?.trim() ?? '';

  if (owner.isEmpty) owner = repoOwner.trim();
  if (repo.isEmpty) repo = 'glxx';
  if (repoNameValue.isEmpty) repoNameValue = repoName.trim();
  if (tag.isEmpty) tag = '${repoNameValue.trim()}-config';

  if (owner.isNotEmpty) {
    await RustKvStore.setString(_configOwnerKey, owner);
  }
  if (repo.isNotEmpty) {
    await RustKvStore.setString(_configRepoKey, repo);
  }
  if (repoNameValue.isNotEmpty) {
    await RustKvStore.setString(_configRepoNameKey, repoNameValue);
  }
  if (tag.isNotEmpty) {
    await RustKvStore.setString(_configTagKey, tag);
  }

  return Uri.https(
    'api.github.com',
    '/repos/$owner/$repo/releases/tags/$tag',
  );
}

Future<RemoteConfig?> _fetchRemoteConfig({required Duration timeout}) async {
  final uri = await _getConfigReleaseUri();

  final client = HttpClient();
  client.connectionTimeout = timeout;
  try {
    final request = await client.getUrl(uri).timeout(timeout);
    request.headers.set(HttpHeaders.userAgentHeader, 'hibiscus');
    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/vnd.github+json',
    );
    final response = await request.close().timeout(timeout);
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != HttpStatus.ok) {
      AppLogger.warn(
        'remote_config',
        'fetch failed: ${response.statusCode} $body',
      );
      return null;
    }

    final releaseJson = jsonDecode(body);
    if (releaseJson is! Map<String, dynamic>) return null;
    final rawConfigBody = (releaseJson['body'] as String?)?.trim() ?? '';
    if (rawConfigBody.isEmpty) return null;

    final configBodyJson = jsonDecode(rawConfigBody);
    if (configBodyJson is! Map<String, dynamic>) return null;

    await RustKvStore.setString(
      _remoteConfigBodyKey,
      jsonEncode(configBodyJson),
    );
    await RustKvStore.setString(
      _remoteConfigLastFetchMsKey,
      DateTime.now().millisecondsSinceEpoch.toString(),
    );

    final cfg = RemoteConfig.fromConfigBodyJson(configBodyJson);
    await _syncOtlpUrl(cfg.otlpUrl);
    return cfg;
  } catch (e, stack) {
    AppLogger.warn('remote_config', 'fetch failed: $e', stack: stack);
    return null;
  } finally {
    client.close(force: true);
  }
}

Future<RemoteConfig?> _handleFetchFailure(int lastMs, int nowMs) async {
  final cached = await loadCachedRemoteConfig();
  if (cached != null) {
    remoteConfigSignal.value = cached;
  } else {
    remoteConfigSignal.value = null;
  }

  if (lastMs > 0 && nowMs - lastMs >= _maxRemoteConfigStale.inMilliseconds) {
    await _clearCachedRemoteConfig();
    remoteConfigSignal.value = null;
    return null;
  }

  return cached;
}

Future<void> _clearCachedRemoteConfig() async {
  await RustKvStore.remove(_remoteConfigBodyKey);
  await RustKvStore.remove(_remoteConfigLastFetchMsKey);
}
