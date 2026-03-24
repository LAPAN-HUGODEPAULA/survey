import 'package:runtime_api_url/runtime_api_url.dart';
import 'package:test/test.dart';

void main() {
  group('normalizeBaseUrl', () {
    test('adds a trailing slash when missing', () {
      expect(
        RuntimeApiUrl.normalizeBaseUrl('/api/v1'),
        equals('/api/v1/'),
      );
    });

    test('preserves an existing trailing slash', () {
      expect(
        RuntimeApiUrl.normalizeBaseUrl('https://example.com/api/v1/'),
        equals('https://example.com/api/v1/'),
      );
    });

    test('throws when the base URL is empty', () {
      expect(
        () => RuntimeApiUrl.normalizeBaseUrl(''),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('dioBaseUrl', () {
    test('removes the trailing slash for Dio base options', () {
      expect(
        RuntimeApiUrl.dioBaseUrl('https://example.com/api/v1/'),
        equals('https://example.com/api/v1'),
      );
    });

    test('keeps a relative API root stable', () {
      expect(RuntimeApiUrl.dioBaseUrl('/api/v1'), equals('/api/v1'));
    });
  });

  group('requestPath', () {
    test('keeps a simple relative path', () {
      expect(
        RuntimeApiUrl.requestPath('/api/v1', 'surveys/'),
        equals('/surveys/'),
      );
    });

    test('removes a duplicated API prefix from an absolute path', () {
      expect(
        RuntimeApiUrl.requestPath('/api/v1/', '/api/v1/screeners/login'),
        equals('/screeners/login'),
      );
    });

    test('does not alter a path when the base URL has no path component', () {
      expect(
        RuntimeApiUrl.requestPath('https://example.com/', '/screeners/login'),
        equals('/screeners/login'),
      );
    });

    test('merges inline and explicit query parameters', () {
      expect(
        RuntimeApiUrl.requestPath(
          'https://example.com/api/v1',
          '/api/v1/surveys/?page=1',
          {'limit': 20},
        ),
        equals('/surveys/?page=1&limit=20'),
      );
    });
  });

  group('resolve', () {
    const relativeBase = '/api/v1/';
    const absoluteBase = 'https://example.com/api/v1/';

    final endpointCases = <({String description, String path, String expected})>[
      (
        description: 'screeners login',
        path: '/screeners/login',
        expected: '/api/v1/screeners/login',
      ),
      (
        description: 'screeners me',
        path: '/screeners/me',
        expected: '/api/v1/screeners/me',
      ),
      (
        description: 'screeners register',
        path: '/screeners/register',
        expected: '/api/v1/screeners/register',
      ),
      (
        description: 'prepared access link creation',
        path: '/screener_access_links/',
        expected: '/api/v1/screener_access_links/',
      ),
      (
        description: 'prepared access link lookup',
        path: '/screener_access_links/token-123',
        expected: '/api/v1/screener_access_links/token-123',
      ),
      (
        description: 'patient response submission',
        path: 'patient_responses/',
        expected: '/api/v1/patient_responses/',
      ),
      (
        description: 'clinical writer proxy',
        path: 'clinical_writer/process',
        expected: '/api/v1/clinical_writer/process',
      ),
      (
        description: 'survey export',
        path: 'surveys/export',
        expected: '/api/v1/surveys/export',
      ),
      (
        description: 'survey listing',
        path: 'surveys/',
        expected: '/api/v1/surveys/',
      ),
      (
        description: 'survey listing with duplicated prefix',
        path: '/api/v1/surveys/',
        expected: '/api/v1/surveys/',
      ),
    ];

    for (final testCase in endpointCases) {
      test('resolves ${testCase.description} against a relative base URL', () {
        expect(
          RuntimeApiUrl.resolve(relativeBase, testCase.path).toString(),
          equals(testCase.expected),
        );
      });

      test('resolves ${testCase.description} against an absolute base URL', () {
        expect(
          RuntimeApiUrl.resolve(absoluteBase, testCase.path).toString(),
          equals('https://example.com${testCase.expected}'),
        );
      });
    }

    test('preserves query parameters for resolved URLs', () {
      expect(
        RuntimeApiUrl.resolve(
          absoluteBase,
          '/api/v1/surveys/',
          {'page': 2, 'pageSize': 50},
        ).toString(),
        equals('https://example.com/api/v1/surveys/?page=2&pageSize=50'),
      );
    });

    test('prevents duplicated api/v1 segments', () {
      expect(
        RuntimeApiUrl.resolve(
          'https://example.com/api/v1/',
          '/api/v1/screener_access_links/token-123',
        ).toString(),
        equals('https://example.com/api/v1/screener_access_links/token-123'),
      );
    });
  });
}
