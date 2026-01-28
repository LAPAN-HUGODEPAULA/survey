import 'package:test/test.dart';
import 'package:survey_backend_api/survey_backend_api.dart';


/// tests for DefaultApi
void main() {
  final instance = SurveyBackendApi().getDefaultApi();

  group(DefaultApi, () {
    // Create patient response
    //
    //Future<SurveyResponseWithAgent> createPatientResponse(SurveyResponse surveyResponse) async
    test('test createPatientResponse', () async {
      // TODO
    });

    // Create survey
    //
    //Future<Survey> createSurvey(Survey survey) async
    test('test createSurvey', () async {
      // TODO
    });

    // Create survey response
    //
    //Future<SurveyResponseWithAgent> createSurveyResponse(SurveyResponse surveyResponse) async
    test('test createSurveyResponse', () async {
      // TODO
    });

    // Get the current screener profile
    //
    //Future<ScreenerProfile> getCurrentScreener(String authorization) async
    test('test getCurrentScreener', () async {
      // TODO
    });

    // Get survey by id
    //
    //Future<Survey> getSurvey(String surveyId) async
    test('test getSurvey', () async {
      // TODO
    });

    // Get survey response by id
    //
    //Future<SurveyResponse> getSurveyResponse(String responseId) async
    test('test getSurveyResponse', () async {
      // TODO
    });

    // List survey responses
    //
    //Future<BuiltList<SurveyResponse>> listSurveyResponses() async
    test('test listSurveyResponses', () async {
      // TODO
    });

    // List surveys
    //
    //Future<BuiltList<Survey>> listSurveys() async
    test('test listSurveys', () async {
      // TODO
    });

    // Authenticate a screener and get an access token
    //
    //Future<Token> loginScreener(ScreenerLogin screenerLogin) async
    test('test loginScreener', () async {
      // TODO
    });

    // Forward content to Clinical Writer
    //
    //Future<AgentResponse> processClinicalWriter(ClinicalWriterRequest clinicalWriterRequest) async
    test('test processClinicalWriter', () async {
      // TODO
    });

    // Request password recovery for a screener
    //
    //Future recoverScreenerPassword(ScreenerPasswordRecoveryRequest screenerPasswordRecoveryRequest) async
    test('test recoverScreenerPassword', () async {
      // TODO
    });

    // Register a new screener
    //
    //Future<ScreenerModel> registerScreener(ScreenerRegister screenerRegister) async
    test('test registerScreener', () async {
      // TODO
    });

    // Resend survey response email
    //
    //Future resendSurveyEmail(String responseId) async
    test('test resendSurveyEmail', () async {
      // TODO
    });

  });
}
