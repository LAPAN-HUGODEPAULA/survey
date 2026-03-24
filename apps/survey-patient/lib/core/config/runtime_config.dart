import 'package:runtime_app_config/runtime_app_config.dart';

class RuntimeConfig {
  RuntimeConfig({required this.apiBaseUrl});

  final String apiBaseUrl;

  static RuntimeConfig? _instance;

  static RuntimeConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError('RuntimeConfig not loaded.');
    }
    return config;
  }

  static Future<void> load() async {
    final loaded = await RuntimeAppConfig.loadStringConfig(
      fallback: {
        'apiBaseUrl': RuntimeAppConfig.resolveApiBaseUrl(),
      },
    );

    _instance = RuntimeConfig(apiBaseUrl: loaded['apiBaseUrl']!);
  }
}
