import 'package:test/test.dart';
import 'package:survey_backend_api/survey_backend_api.dart';


/// tests for DefaultApi
void main() {
  final instance = SurveyBackendApi().getDefaultApi();

  group(DefaultApi, () {
    // Analyze conversation context with Clinical Writer
    //
    //Future<ClinicalWriterAnalysisResponse> analyzeClinicalWriter(ClinicalWriterAnalysisRequest clinicalWriterAnalysisRequest) async
    test('test analyzeClinicalWriter', () async {
      // TODO
    });

    // Approve template
    //
    //Future<TemplateRecord> approveTemplate(String templateId) async
    test('test approveTemplate', () async {
      // TODO
    });

    // Archive template
    //
    //Future<TemplateRecord> archiveTemplate(String templateId) async
    test('test archiveTemplate', () async {
      // TODO
    });

    // Complete chat session
    //
    //Future<ChatSession> completeChatSession(String sessionId) async
    test('test completeChatSession', () async {
      // TODO
    });

    // Create chat message
    //
    //Future<ChatMessage> createChatMessage(String sessionId, ChatMessageCreate chatMessageCreate) async
    test('test createChatMessage', () async {
      // TODO
    });

    // Create chat session
    //
    //Future<ChatSession> createChatSession(ChatSessionCreate chatSessionCreate) async
    test('test createChatSession', () async {
      // TODO
    });

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

    // Create template
    //
    //Future<TemplateRecord> createTemplate(TemplateCreateRequest templateCreateRequest) async
    test('test createTemplate', () async {
      // TODO
    });

    // Delete survey
    //
    //Future deleteSurvey(String surveyId) async
    test('test deleteSurvey', () async {
      // TODO
    });

    // Export document
    //
    //Future<DocumentRecord> exportDocument(DocumentExportRequest documentExportRequest) async
    test('test exportDocument', () async {
      // TODO
    });

    // Get chat session
    //
    //Future<ChatSession> getChatSession(String sessionId) async
    test('test getChatSession', () async {
      // TODO
    });

    // Get the current screener profile
    //
    //Future<ScreenerProfile> getCurrentScreener(String authorization) async
    test('test getCurrentScreener', () async {
      // TODO
    });

    // Get document record
    //
    //Future<DocumentRecord> getDocument(String documentId) async
    test('test getDocument', () async {
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

    // Get template
    //
    //Future<TemplateRecord> getTemplate(String templateId) async
    test('test getTemplate', () async {
      // TODO
    });

    // List chat messages
    //
    //Future<BuiltList<ChatMessage>> listChatMessages(String sessionId) async
    test('test listChatMessages', () async {
      // TODO
    });

    // List chat sessions
    //
    //Future<BuiltList<ChatSession>> listChatSessions({ String status }) async
    test('test listChatSessions', () async {
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

    // List supported template document types
    //
    //Future<BuiltList<ListTemplateDocumentTypes200ResponseInner>> listTemplateDocumentTypes() async
    test('test listTemplateDocumentTypes', () async {
      // TODO
    });

    // List templates
    //
    //Future<BuiltList<TemplateRecord>> listTemplates({ TemplateDocumentType documentType, String q, bool includeAll }) async
    test('test listTemplates', () async {
      // TODO
    });

    // Authenticate a screener and get an access token
    //
    //Future<Token> loginScreener(ScreenerLogin screenerLogin) async
    test('test loginScreener', () async {
      // TODO
    });

    // Generate document preview
    //
    //Future<DocumentPreview> previewDocument(DocumentPreviewRequest documentPreviewRequest) async
    test('test previewDocument', () async {
      // TODO
    });

    // Preview template
    //
    //Future<TemplatePreviewResponse> previewTemplate(String templateId, TemplatePreviewRequest templatePreviewRequest) async
    test('test previewTemplate', () async {
      // TODO
    });

    // Forward content to Clinical Writer
    //
    //Future<AgentResponse> processClinicalWriter(ClinicalWriterRequest clinicalWriterRequest) async
    test('test processClinicalWriter', () async {
      // TODO
    });

    // Recommend templates
    //
    //Future<BuiltList<TemplateRecord>> recommendTemplates({ TemplateDocumentType documentType }) async
    test('test recommendTemplates', () async {
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
    //Future<ScreenerProfile> registerScreener(ScreenerRegister screenerRegister) async
    test('test registerScreener', () async {
      // TODO
    });

    // Resend survey response email
    //
    //Future resendSurveyEmail(String responseId) async
    test('test resendSurveyEmail', () async {
      // TODO
    });

    // Transcribe voice audio
    //
    //Future<TranscriptionResponse> transcribeVoiceAudio(TranscriptionRequest transcriptionRequest) async
    test('test transcribeVoiceAudio', () async {
      // TODO
    });

    // Update chat message
    //
    //Future<ChatMessage> updateChatMessage(String messageId, ChatMessageUpdate chatMessageUpdate) async
    test('test updateChatMessage', () async {
      // TODO
    });

    // Update chat session
    //
    //Future<ChatSession> updateChatSession(String sessionId, ChatSessionUpdate chatSessionUpdate) async
    test('test updateChatSession', () async {
      // TODO
    });

    // Update survey
    //
    //Future<Survey> updateSurvey(String surveyId, Survey survey) async
    test('test updateSurvey', () async {
      // TODO
    });

    // Update template (new version)
    //
    //Future<TemplateRecord> updateTemplate(String templateId, TemplateUpdateRequest templateUpdateRequest) async
    test('test updateTemplate', () async {
      // TODO
    });

  });
}
