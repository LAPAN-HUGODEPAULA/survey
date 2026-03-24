import 'package:runtime_app_config/runtime_app_config.dart';
import 'package:test/test.dart';

void main() {
  group('resolveApiBaseUrl', () {
    test('returns API_BASE_URL when explicitly provided', () {
      expect(
        RuntimeAppConfig.resolveApiBaseUrl(
          apiBaseUrlEnv: 'https://example.com/api/v1',
          flavor: 'firebase',
        ),
        equals('https://example.com/api/v1'),
      );
    });

    test('defaults dockerVps builds to /api/v1 when API_BASE_URL is empty', () {
      expect(
        RuntimeAppConfig.resolveApiBaseUrl(
          apiBaseUrlEnv: '',
          flavor: 'dockerVps',
        ),
        equals('/api/v1'),
      );
    });

    test('throws for non-docker flavors without API_BASE_URL', () {
      expect(
        () => RuntimeAppConfig.resolveApiBaseUrl(
          apiBaseUrlEnv: '',
          flavor: 'firebase',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('mergeStringConfig', () {
    test('overrides only known fallback keys', () {
      final merged = RuntimeAppConfig.mergeStringConfig(
        fallback: {
          'apiBaseUrl': '/api/v1',
          'viaCepBaseUrl': 'https://viacep.com.br/',
        },
        raw: {
          'apiBaseUrl': 'https://example.com/api/v1',
          'viaCepBaseUrl': 'https://custom.example/',
          'ignored': 'value',
        },
      );

      expect(
        merged,
        equals({
          'apiBaseUrl': 'https://example.com/api/v1',
          'viaCepBaseUrl': 'https://custom.example/',
        }),
      );
    });

    test('falls back when decoded JSON is not a map', () {
      final merged = RuntimeAppConfig.mergeStringConfig(
        fallback: {'apiBaseUrl': '/api/v1'},
        raw: ['unexpected'],
      );

      expect(merged, equals({'apiBaseUrl': '/api/v1'}));
    });
  });

  group('loadStringConfig', () {
    test('loads config.json values when available', () async {
      final loaded = await RuntimeAppConfig.loadStringConfig(
        fallback: {
          'apiBaseUrl': '/api/v1',
          'viaCepBaseUrl': 'https://viacep.com.br/',
        },
        baseUri: Uri.parse('https://app.example/'),
        fetcher: (uri) async {
          expect(uri.toString(), equals('https://app.example/config.json'));
          return {
            'apiBaseUrl': 'https://api.example/api/v1',
            'viaCepBaseUrl': 'https://custom.example/',
          };
        },
      );

      expect(
        loaded,
        equals({
          'apiBaseUrl': 'https://api.example/api/v1',
          'viaCepBaseUrl': 'https://custom.example/',
        }),
      );
    });

    test('falls back when config.json cannot be loaded', () async {
      final loaded = await RuntimeAppConfig.loadStringConfig(
        fallback: {'apiBaseUrl': '/api/v1'},
        fetcher: (_) async => throw Exception('boom'),
      );

      expect(loaded, equals({'apiBaseUrl': '/api/v1'}));
    });
  });
}
