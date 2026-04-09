import 'package:test/test.dart';
import 'package:survey_backend_api/survey_backend_api.dart';

// tests for ApiError
void main() {
  final instance = ApiErrorBuilder();
  // TODO add properties to the builder and call build()

  group(ApiError, () {
    // Stable string identifier for the error category
    // String code
    test('to test the property `code`', () async {
      // TODO
    });

    // Localized, human-readable message in pt-BR
    // String userMessage
    test('to test the property `userMessage`', () async {
      // TODO
    });

    // String severity (default value: 'error')
    test('to test the property `severity`', () async {
      // TODO
    });

    // bool retryable (default value: false)
    test('to test the property `retryable`', () async {
      // TODO
    });

    // String requestId
    test('to test the property `requestId`', () async {
      // TODO
    });

    // String operation
    test('to test the property `operation`', () async {
      // TODO
    });

    // String stage
    test('to test the property `stage`', () async {
      // TODO
    });

    // BuiltList<JsonObject> details
    test('to test the property `details`', () async {
      // TODO
    });

  });
}
