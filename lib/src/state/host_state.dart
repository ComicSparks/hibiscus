// Active host (域名) 相关状态

import 'package:flutter/foundation.dart';
import 'package:hibiscus/src/rust/api/settings.dart' as settings_api;
import 'package:signals/signals_flutter.dart';

class HostChoice {
  final String host;
  final bool useCustomDns;
  final String label;
  final String description;

  const HostChoice({
    required this.host,
    required this.useCustomDns,
    required this.label,
    required this.description,
  });
}

@immutable
class ActiveHostInfo {
  final String host;
  final bool useCustomDns;
  final String label;

  const ActiveHostInfo({
    required this.host,
    required this.useCustomDns,
    required this.label,
  });

  String get baseUrl => 'https://$host';
  String get loginUrl => '$baseUrl/login';
  String get referer => '$baseUrl/';
}

const List<HostChoice> _hostChoices = [
  HostChoice(
    host: 'hanime1.me',
    useCustomDns: true,
    label: 'hanime1.me（自定义 DNS）',
    description: '使用内置 Cloudflare IP（绕过 DNS 污染）。',
  ),
  HostChoice(
    host: 'hanime1.me',
    useCustomDns: false,
    label: 'hanime1.me（官方 DNS）',
    description: '使用系统 DNS 解析域名 IP。',
  ),
  // HostChoice(
  //   host: 'hanimeone.me',
  //   useCustomDns: false,
  //   label: 'hanimeone.me',
  //   description: '备用域名，Cookie/登录状态独立。',
  // ),
  // HostChoice(
  //   host: 'javchu.com',
  //   useCustomDns: false,
  //   label: 'javchu.com',
  //   description: '备用域名，Cookie/登录状态独立。',
  // ),
];

class ActiveHostState {
  static final ActiveHostState instance = ActiveHostState._();
  ActiveHostState._();

  final activeHost = signal(_hostChoices.first.toActiveHostInfo());

  List<HostChoice> get choices => _hostChoices;

  HostChoice get _defaultChoice => _hostChoices.first;

  HostChoice _choiceFor(String host, bool useCustomDns) {
    final exact = choices.firstWhere(
      (choice) => choice.host == host && choice.useCustomDns == useCustomDns,
      orElse: () => _defaultChoice,
    );
    if (exact.host == host && exact.useCustomDns == useCustomDns) {
      return exact;
    }

    return choices.firstWhere(
      (choice) => choice.host == host,
      orElse: () => _defaultChoice,
    );
  }

  Future<void> init() async {
    final storedHost = (await settings_api.getKv(key: 'network.active_host'))?.trim();
    final storedDns = (await settings_api.getKv(key: 'network.use_custom_dns'))?.trim();
    final host = storedHost?.isNotEmpty == true ? storedHost! : _defaultChoice.host;
    final bool useCustomDns = storedDns?.isNotEmpty == true
        ? storedDns!.toLowerCase() == 'true'
        : _defaultChoice.useCustomDns;

    final normalizedChoice = _choiceFor(host, useCustomDns);
    activeHost.value = normalizedChoice.toActiveHostInfo();
  }

  Future<void> setActiveHost(HostChoice choice) async {
    await settings_api.setKv(key: 'network.active_host', value: choice.host);
    await settings_api.setKv(
      key: 'network.use_custom_dns',
      value: choice.useCustomDns.toString(),
    );
    activeHost.value = choice.toActiveHostInfo();
  }
}

extension on HostChoice {
  ActiveHostInfo toActiveHostInfo() {
    return ActiveHostInfo(
      host: host,
      useCustomDns: useCustomDns,
      label: label,
    );
  }
}

final activeHostState = ActiveHostState.instance;
