# survey_backend_api.api.DefaultApi

## Load the API package
```dart
import 'package:survey_backend_api/api.dart';
```

All URIs are relative to **

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptScreenerInitialNoticeAgreement**](DefaultApi.md#acceptscreenerinitialnoticeagreement) | **POST** /screeners/me/initial-notice-agreement | Record the current screener initial notice agreement
[**analyzeClinicalWriter**](DefaultApi.md#analyzeclinicalwriter) | **POST** /clinical_writer/analysis | Analyze conversation context with Clinical Writer
[**approveTemplate**](DefaultApi.md#approvetemplate) | **POST** /templates/{templateId}/approve | Approve template
[**archiveTemplate**](DefaultApi.md#archivetemplate) | **POST** /templates/{templateId}/archive | Archive template
[**completeChatSession**](DefaultApi.md#completechatsession) | **POST** /chat/sessions/{sessionId}/complete | Complete chat session
[**createAgentAccessPoint**](DefaultApi.md#createagentaccesspoint) | **POST** /agent_access_points/ | Create agent access point
[**createChatMessage**](DefaultApi.md#createchatmessage) | **POST** /chat/sessions/{sessionId}/messages | Create chat message
[**createChatSession**](DefaultApi.md#createchatsession) | **POST** /chat/sessions | Create chat session
[**createPatientResponse**](DefaultApi.md#createpatientresponse) | **POST** /patient_responses/ | Create patient response
[**createPersonaSkill**](DefaultApi.md#createpersonaskill) | **POST** /persona_skills/ | Create persona skill
[**createScreenerAccessLink**](DefaultApi.md#createscreeneraccesslink) | **POST** /screener_access_links/ | Create a prepared screener access link
[**createSurvey**](DefaultApi.md#createsurvey) | **POST** /surveys/ | Create survey
[**createSurveyPrompt**](DefaultApi.md#createsurveyprompt) | **POST** /survey_prompts/ | Create reusable survey prompt
[**createSurveyResponse**](DefaultApi.md#createsurveyresponse) | **POST** /survey_responses/ | Create survey response
[**createTemplate**](DefaultApi.md#createtemplate) | **POST** /templates | Create template
[**deleteAgentAccessPoint**](DefaultApi.md#deleteagentaccesspoint) | **DELETE** /agent_access_points/{accessPointKey} | Delete agent access point
[**deletePersonaSkill**](DefaultApi.md#deletepersonaskill) | **DELETE** /persona_skills/{personaSkillKey} | Delete persona skill
[**deleteSurvey**](DefaultApi.md#deletesurvey) | **DELETE** /surveys/{surveyId} | Delete survey
[**deleteSurveyPrompt**](DefaultApi.md#deletesurveyprompt) | **DELETE** /survey_prompts/{promptKey} | Delete reusable survey prompt
[**exportDocument**](DefaultApi.md#exportdocument) | **POST** /documents/export | Export document
[**exportSurveys**](DefaultApi.md#exportsurveys) | **GET** /surveys/export | Export surveys
[**getAgentAccessPoint**](DefaultApi.md#getagentaccesspoint) | **GET** /agent_access_points/{accessPointKey} | Get agent access point by key
[**getBuilderSession**](DefaultApi.md#getbuildersession) | **GET** /builder/session | Resolve the current builder administrator session
[**getChatSession**](DefaultApi.md#getchatsession) | **GET** /chat/sessions/{sessionId} | Get chat session
[**getClinicalWriterStatus**](DefaultApi.md#getclinicalwriterstatus) | **GET** /clinical_writer/status/{task_id} | Get asynchronous Clinical Writer task status
[**getCurrentScreener**](DefaultApi.md#getcurrentscreener) | **GET** /screeners/me | Get the current screener profile
[**getDocument**](DefaultApi.md#getdocument) | **GET** /documents/{documentId} | Get document record
[**getPersonaSkill**](DefaultApi.md#getpersonaskill) | **GET** /persona_skills/{personaSkillKey} | Get persona skill by key
[**getSurvey**](DefaultApi.md#getsurvey) | **GET** /surveys/{surveyId} | Get survey by id
[**getSurveyPrompt**](DefaultApi.md#getsurveyprompt) | **GET** /survey_prompts/{promptKey} | Get reusable survey prompt by key
[**getSurveyResponse**](DefaultApi.md#getsurveyresponse) | **GET** /survey_responses/{responseId} | Get survey response by id
[**getTemplate**](DefaultApi.md#gettemplate) | **GET** /templates/{templateId} | Get template
[**listAgentAccessPoints**](DefaultApi.md#listagentaccesspoints) | **GET** /agent_access_points/ | List agent access points
[**listChatMessages**](DefaultApi.md#listchatmessages) | **GET** /chat/sessions/{sessionId}/messages | List chat messages
[**listChatSessions**](DefaultApi.md#listchatsessions) | **GET** /chat/sessions | List chat sessions
[**listPersonaSkills**](DefaultApi.md#listpersonaskills) | **GET** /persona_skills/ | List persona skills
[**listSurveyPrompts**](DefaultApi.md#listsurveyprompts) | **GET** /survey_prompts/ | List reusable survey prompts
[**listSurveyResponses**](DefaultApi.md#listsurveyresponses) | **GET** /survey_responses/ | List survey responses
[**listSurveys**](DefaultApi.md#listsurveys) | **GET** /surveys/ | List surveys
[**listTemplateDocumentTypes**](DefaultApi.md#listtemplatedocumenttypes) | **GET** /templates/document-types | List supported template document types
[**listTemplates**](DefaultApi.md#listtemplates) | **GET** /templates | List templates
[**loginBuilder**](DefaultApi.md#loginbuilder) | **POST** /builder/login | Authenticate a builder administrator and issue a cookie-backed session
[**loginScreener**](DefaultApi.md#loginscreener) | **POST** /screeners/login | Authenticate a screener and get an access token
[**logoutBuilder**](DefaultApi.md#logoutbuilder) | **POST** /builder/logout | Clear the current builder administrator session
[**previewDocument**](DefaultApi.md#previewdocument) | **POST** /documents/preview | Generate document preview
[**previewTemplate**](DefaultApi.md#previewtemplate) | **POST** /templates/{templateId}/preview | Preview template
[**processClinicalWriter**](DefaultApi.md#processclinicalwriter) | **POST** /clinical_writer/process | Forward content to Clinical Writer
[**recommendTemplates**](DefaultApi.md#recommendtemplates) | **GET** /templates/recommendations | Recommend templates
[**recoverScreenerPassword**](DefaultApi.md#recoverscreenerpassword) | **POST** /screeners/recover-password | Request password recovery for a screener
[**registerScreener**](DefaultApi.md#registerscreener) | **POST** /screeners/register | Register a new screener
[**resendSurveyEmail**](DefaultApi.md#resendsurveyemail) | **POST** /survey_responses/{responseId}/send_email | Resend survey response email
[**resolveScreenerAccessLink**](DefaultApi.md#resolvescreeneraccesslink) | **GET** /screener_access_links/{token} | Resolve a prepared screener access link
[**transcribeVoiceAudio**](DefaultApi.md#transcribevoiceaudio) | **POST** /voice/transcriptions | Transcribe voice audio
[**updateAgentAccessPoint**](DefaultApi.md#updateagentaccesspoint) | **PUT** /agent_access_points/{accessPointKey} | Update agent access point
[**updateChatMessage**](DefaultApi.md#updatechatmessage) | **PATCH** /chat/messages/{messageId} | Update chat message
[**updateChatSession**](DefaultApi.md#updatechatsession) | **PATCH** /chat/sessions/{sessionId} | Update chat session
[**updatePersonaSkill**](DefaultApi.md#updatepersonaskill) | **PUT** /persona_skills/{personaSkillKey} | Update persona skill
[**updateSurvey**](DefaultApi.md#updatesurvey) | **PUT** /surveys/{surveyId} | Update survey
[**updateSurveyPrompt**](DefaultApi.md#updatesurveyprompt) | **PUT** /survey_prompts/{promptKey} | Update reusable survey prompt
[**updateTemplate**](DefaultApi.md#updatetemplate) | **PUT** /templates/{templateId} | Update template (new version)


# **acceptScreenerInitialNoticeAgreement**
> ScreenerProfile acceptScreenerInitialNoticeAgreement(authorization)

Record the current screener initial notice agreement

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String authorization = authorization_example; // String | Bearer token in the format `Bearer <token>`

try {
    final response = api.acceptScreenerInitialNoticeAgreement(authorization);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->acceptScreenerInitialNoticeAgreement: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token in the format `Bearer <token>` | 

### Return type

[**ScreenerProfile**](ScreenerProfile.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **analyzeClinicalWriter**
> ClinicalWriterAnalysisResponse analyzeClinicalWriter(clinicalWriterAnalysisRequest)

Analyze conversation context with Clinical Writer

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final ClinicalWriterAnalysisRequest clinicalWriterAnalysisRequest = ; // ClinicalWriterAnalysisRequest | 

try {
    final response = api.analyzeClinicalWriter(clinicalWriterAnalysisRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->analyzeClinicalWriter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **clinicalWriterAnalysisRequest** | [**ClinicalWriterAnalysisRequest**](ClinicalWriterAnalysisRequest.md)|  | 

### Return type

[**ClinicalWriterAnalysisResponse**](ClinicalWriterAnalysisResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **approveTemplate**
> TemplateRecord approveTemplate(templateId)

Approve template

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String templateId = templateId_example; // String | 

try {
    final response = api.approveTemplate(templateId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->approveTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **templateId** | **String**|  | 

### Return type

[**TemplateRecord**](TemplateRecord.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **archiveTemplate**
> TemplateRecord archiveTemplate(templateId)

Archive template

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String templateId = templateId_example; // String | 

try {
    final response = api.archiveTemplate(templateId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->archiveTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **templateId** | **String**|  | 

### Return type

[**TemplateRecord**](TemplateRecord.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **completeChatSession**
> ChatSession completeChatSession(sessionId)

Complete chat session

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String sessionId = sessionId_example; // String | 

try {
    final response = api.completeChatSession(sessionId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->completeChatSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  | 

### Return type

[**ChatSession**](ChatSession.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createAgentAccessPoint**
> AgentAccessPoint createAgentAccessPoint(agentAccessPointUpsert)

Create agent access point

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final AgentAccessPointUpsert agentAccessPointUpsert = ; // AgentAccessPointUpsert | 

try {
    final response = api.createAgentAccessPoint(agentAccessPointUpsert);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createAgentAccessPoint: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **agentAccessPointUpsert** | [**AgentAccessPointUpsert**](AgentAccessPointUpsert.md)|  | 

### Return type

[**AgentAccessPoint**](AgentAccessPoint.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createChatMessage**
> ChatMessage createChatMessage(sessionId, chatMessageCreate)

Create chat message

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String sessionId = sessionId_example; // String | 
final ChatMessageCreate chatMessageCreate = ; // ChatMessageCreate | 

try {
    final response = api.createChatMessage(sessionId, chatMessageCreate);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createChatMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  | 
 **chatMessageCreate** | [**ChatMessageCreate**](ChatMessageCreate.md)|  | 

### Return type

[**ChatMessage**](ChatMessage.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createChatSession**
> ChatSession createChatSession(chatSessionCreate)

Create chat session

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final ChatSessionCreate chatSessionCreate = ; // ChatSessionCreate | 

try {
    final response = api.createChatSession(chatSessionCreate);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createChatSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatSessionCreate** | [**ChatSessionCreate**](ChatSessionCreate.md)|  | 

### Return type

[**ChatSession**](ChatSession.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPatientResponse**
> SurveyResponseWithAgent createPatientResponse(surveyResponse)

Create patient response

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final SurveyResponse surveyResponse = ; // SurveyResponse | 

try {
    final response = api.createPatientResponse(surveyResponse);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createPatientResponse: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **surveyResponse** | [**SurveyResponse**](SurveyResponse.md)|  | 

### Return type

[**SurveyResponseWithAgent**](SurveyResponseWithAgent.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPersonaSkill**
> PersonaSkill createPersonaSkill(personaSkillUpsert)

Create persona skill

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final PersonaSkillUpsert personaSkillUpsert = ; // PersonaSkillUpsert | 

try {
    final response = api.createPersonaSkill(personaSkillUpsert);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createPersonaSkill: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **personaSkillUpsert** | [**PersonaSkillUpsert**](PersonaSkillUpsert.md)|  | 

### Return type

[**PersonaSkill**](PersonaSkill.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createScreenerAccessLink**
> ScreenerAccessLink createScreenerAccessLink(authorization, createScreenerAccessLinkRequest)

Create a prepared screener access link

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String authorization = authorization_example; // String | Bearer token in the format `Bearer <token>`
final CreateScreenerAccessLinkRequest createScreenerAccessLinkRequest = ; // CreateScreenerAccessLinkRequest | 

try {
    final response = api.createScreenerAccessLink(authorization, createScreenerAccessLinkRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createScreenerAccessLink: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token in the format `Bearer <token>` | 
 **createScreenerAccessLinkRequest** | [**CreateScreenerAccessLinkRequest**](CreateScreenerAccessLinkRequest.md)|  | 

### Return type

[**ScreenerAccessLink**](ScreenerAccessLink.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createSurvey**
> Survey createSurvey(survey)

Create survey

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final Survey survey = ; // Survey | 

try {
    final response = api.createSurvey(survey);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createSurvey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **survey** | [**Survey**](Survey.md)|  | 

### Return type

[**Survey**](Survey.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createSurveyPrompt**
> SurveyPrompt createSurveyPrompt(surveyPromptUpsert)

Create reusable survey prompt

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final SurveyPromptUpsert surveyPromptUpsert = ; // SurveyPromptUpsert | 

try {
    final response = api.createSurveyPrompt(surveyPromptUpsert);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createSurveyPrompt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **surveyPromptUpsert** | [**SurveyPromptUpsert**](SurveyPromptUpsert.md)|  | 

### Return type

[**SurveyPrompt**](SurveyPrompt.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createSurveyResponse**
> SurveyResponseWithAgent createSurveyResponse(surveyResponse)

Create survey response

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final SurveyResponse surveyResponse = ; // SurveyResponse | 

try {
    final response = api.createSurveyResponse(surveyResponse);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createSurveyResponse: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **surveyResponse** | [**SurveyResponse**](SurveyResponse.md)|  | 

### Return type

[**SurveyResponseWithAgent**](SurveyResponseWithAgent.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTemplate**
> TemplateRecord createTemplate(templateCreateRequest)

Create template

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final TemplateCreateRequest templateCreateRequest = ; // TemplateCreateRequest | 

try {
    final response = api.createTemplate(templateCreateRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **templateCreateRequest** | [**TemplateCreateRequest**](TemplateCreateRequest.md)|  | 

### Return type

[**TemplateRecord**](TemplateRecord.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteAgentAccessPoint**
> deleteAgentAccessPoint(accessPointKey)

Delete agent access point

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String accessPointKey = accessPointKey_example; // String | 

try {
    api.deleteAgentAccessPoint(accessPointKey);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->deleteAgentAccessPoint: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **accessPointKey** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deletePersonaSkill**
> deletePersonaSkill(personaSkillKey)

Delete persona skill

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String personaSkillKey = personaSkillKey_example; // String | 

try {
    api.deletePersonaSkill(personaSkillKey);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->deletePersonaSkill: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **personaSkillKey** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteSurvey**
> deleteSurvey(surveyId)

Delete survey

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String surveyId = surveyId_example; // String | 

try {
    api.deleteSurvey(surveyId);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->deleteSurvey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **surveyId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteSurveyPrompt**
> deleteSurveyPrompt(promptKey)

Delete reusable survey prompt

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String promptKey = promptKey_example; // String | 

try {
    api.deleteSurveyPrompt(promptKey);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->deleteSurveyPrompt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **promptKey** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **exportDocument**
> DocumentRecord exportDocument(documentExportRequest)

Export document

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final DocumentExportRequest documentExportRequest = ; // DocumentExportRequest | 

try {
    final response = api.exportDocument(documentExportRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->exportDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentExportRequest** | [**DocumentExportRequest**](DocumentExportRequest.md)|  | 

### Return type

[**DocumentRecord**](DocumentRecord.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **exportSurveys**
> BuiltList<Survey> exportSurveys()

Export surveys

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();

try {
    final response = api.exportSurveys();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->exportSurveys: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Survey&gt;**](Survey.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAgentAccessPoint**
> AgentAccessPoint getAgentAccessPoint(accessPointKey)

Get agent access point by key

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String accessPointKey = accessPointKey_example; // String | 

try {
    final response = api.getAgentAccessPoint(accessPointKey);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getAgentAccessPoint: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **accessPointKey** | **String**|  | 

### Return type

[**AgentAccessPoint**](AgentAccessPoint.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBuilderSession**
> BuilderSessionResponse getBuilderSession()

Resolve the current builder administrator session

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();

try {
    final response = api.getBuilderSession();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getBuilderSession: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuilderSessionResponse**](BuilderSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChatSession**
> ChatSession getChatSession(sessionId)

Get chat session

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String sessionId = sessionId_example; // String | 

try {
    final response = api.getChatSession(sessionId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getChatSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  | 

### Return type

[**ChatSession**](ChatSession.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getClinicalWriterStatus**
> ClinicalWriterTaskResponse getClinicalWriterStatus(taskId)

Get asynchronous Clinical Writer task status

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String taskId = taskId_example; // String | 

try {
    final response = api.getClinicalWriterStatus(taskId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getClinicalWriterStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **taskId** | **String**|  | 

### Return type

[**ClinicalWriterTaskResponse**](ClinicalWriterTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCurrentScreener**
> ScreenerProfile getCurrentScreener(authorization)

Get the current screener profile

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String authorization = authorization_example; // String | Bearer token in the format `Bearer <token>`

try {
    final response = api.getCurrentScreener(authorization);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getCurrentScreener: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token in the format `Bearer <token>` | 

### Return type

[**ScreenerProfile**](ScreenerProfile.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDocument**
> DocumentRecord getDocument(documentId)

Get document record

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String documentId = documentId_example; // String | 

try {
    final response = api.getDocument(documentId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentId** | **String**|  | 

### Return type

[**DocumentRecord**](DocumentRecord.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPersonaSkill**
> PersonaSkill getPersonaSkill(personaSkillKey)

Get persona skill by key

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String personaSkillKey = personaSkillKey_example; // String | 

try {
    final response = api.getPersonaSkill(personaSkillKey);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getPersonaSkill: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **personaSkillKey** | **String**|  | 

### Return type

[**PersonaSkill**](PersonaSkill.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSurvey**
> Survey getSurvey(surveyId)

Get survey by id

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String surveyId = surveyId_example; // String | 

try {
    final response = api.getSurvey(surveyId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getSurvey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **surveyId** | **String**|  | 

### Return type

[**Survey**](Survey.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSurveyPrompt**
> SurveyPrompt getSurveyPrompt(promptKey)

Get reusable survey prompt by key

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String promptKey = promptKey_example; // String | 

try {
    final response = api.getSurveyPrompt(promptKey);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getSurveyPrompt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **promptKey** | **String**|  | 

### Return type

[**SurveyPrompt**](SurveyPrompt.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSurveyResponse**
> SurveyResponse getSurveyResponse(responseId)

Get survey response by id

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String responseId = responseId_example; // String | 

try {
    final response = api.getSurveyResponse(responseId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getSurveyResponse: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **responseId** | **String**|  | 

### Return type

[**SurveyResponse**](SurveyResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTemplate**
> TemplateRecord getTemplate(templateId)

Get template

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String templateId = templateId_example; // String | 

try {
    final response = api.getTemplate(templateId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **templateId** | **String**|  | 

### Return type

[**TemplateRecord**](TemplateRecord.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAgentAccessPoints**
> BuiltList<AgentAccessPoint> listAgentAccessPoints()

List agent access points

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();

try {
    final response = api.listAgentAccessPoints();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->listAgentAccessPoints: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;AgentAccessPoint&gt;**](AgentAccessPoint.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listChatMessages**
> BuiltList<ChatMessage> listChatMessages(sessionId)

List chat messages

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String sessionId = sessionId_example; // String | 

try {
    final response = api.listChatMessages(sessionId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->listChatMessages: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  | 

### Return type

[**BuiltList&lt;ChatMessage&gt;**](ChatMessage.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listChatSessions**
> BuiltList<ChatSession> listChatSessions(status)

List chat sessions

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String status = status_example; // String | 

try {
    final response = api.listChatSessions(status);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->listChatSessions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **status** | **String**|  | [optional] 

### Return type

[**BuiltList&lt;ChatSession&gt;**](ChatSession.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPersonaSkills**
> BuiltList<PersonaSkill> listPersonaSkills()

List persona skills

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();

try {
    final response = api.listPersonaSkills();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->listPersonaSkills: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;PersonaSkill&gt;**](PersonaSkill.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSurveyPrompts**
> BuiltList<SurveyPrompt> listSurveyPrompts()

List reusable survey prompts

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();

try {
    final response = api.listSurveyPrompts();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->listSurveyPrompts: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;SurveyPrompt&gt;**](SurveyPrompt.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSurveyResponses**
> BuiltList<SurveyResponse> listSurveyResponses()

List survey responses

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();

try {
    final response = api.listSurveyResponses();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->listSurveyResponses: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;SurveyResponse&gt;**](SurveyResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSurveys**
> BuiltList<Survey> listSurveys()

List surveys

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();

try {
    final response = api.listSurveys();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->listSurveys: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Survey&gt;**](Survey.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTemplateDocumentTypes**
> BuiltList<ListTemplateDocumentTypes200ResponseInner> listTemplateDocumentTypes()

List supported template document types

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();

try {
    final response = api.listTemplateDocumentTypes();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->listTemplateDocumentTypes: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;ListTemplateDocumentTypes200ResponseInner&gt;**](ListTemplateDocumentTypes200ResponseInner.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTemplates**
> BuiltList<TemplateRecord> listTemplates(documentType, q, includeAll)

List templates

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final TemplateDocumentType documentType = ; // TemplateDocumentType | 
final String q = q_example; // String | 
final bool includeAll = true; // bool | 

try {
    final response = api.listTemplates(documentType, q, includeAll);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->listTemplates: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentType** | [**TemplateDocumentType**](.md)|  | [optional] 
 **q** | **String**|  | [optional] 
 **includeAll** | **bool**|  | [optional] 

### Return type

[**BuiltList&lt;TemplateRecord&gt;**](TemplateRecord.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loginBuilder**
> BuilderSessionResponse loginBuilder(screenerLogin)

Authenticate a builder administrator and issue a cookie-backed session

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final ScreenerLogin screenerLogin = ; // ScreenerLogin | 

try {
    final response = api.loginBuilder(screenerLogin);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->loginBuilder: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **screenerLogin** | [**ScreenerLogin**](ScreenerLogin.md)|  | 

### Return type

[**BuilderSessionResponse**](BuilderSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loginScreener**
> Token loginScreener(screenerLogin)

Authenticate a screener and get an access token

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final ScreenerLogin screenerLogin = ; // ScreenerLogin | 

try {
    final response = api.loginScreener(screenerLogin);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->loginScreener: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **screenerLogin** | [**ScreenerLogin**](ScreenerLogin.md)|  | 

### Return type

[**Token**](Token.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logoutBuilder**
> logoutBuilder()

Clear the current builder administrator session

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();

try {
    api.logoutBuilder();
} catch on DioException (e) {
    print('Exception when calling DefaultApi->logoutBuilder: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **previewDocument**
> DocumentPreview previewDocument(documentPreviewRequest)

Generate document preview

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final DocumentPreviewRequest documentPreviewRequest = ; // DocumentPreviewRequest | 

try {
    final response = api.previewDocument(documentPreviewRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->previewDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentPreviewRequest** | [**DocumentPreviewRequest**](DocumentPreviewRequest.md)|  | 

### Return type

[**DocumentPreview**](DocumentPreview.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **previewTemplate**
> TemplatePreviewResponse previewTemplate(templateId, templatePreviewRequest)

Preview template

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String templateId = templateId_example; // String | 
final TemplatePreviewRequest templatePreviewRequest = ; // TemplatePreviewRequest | 

try {
    final response = api.previewTemplate(templateId, templatePreviewRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->previewTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **templateId** | **String**|  | 
 **templatePreviewRequest** | [**TemplatePreviewRequest**](TemplatePreviewRequest.md)|  | 

### Return type

[**TemplatePreviewResponse**](TemplatePreviewResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **processClinicalWriter**
> ProcessClinicalWriter200Response processClinicalWriter(clinicalWriterRequest)

Forward content to Clinical Writer

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final ClinicalWriterRequest clinicalWriterRequest = ; // ClinicalWriterRequest | 

try {
    final response = api.processClinicalWriter(clinicalWriterRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->processClinicalWriter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **clinicalWriterRequest** | [**ClinicalWriterRequest**](ClinicalWriterRequest.md)|  | 

### Return type

[**ProcessClinicalWriter200Response**](ProcessClinicalWriter200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recommendTemplates**
> BuiltList<TemplateRecord> recommendTemplates(documentType)

Recommend templates

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final TemplateDocumentType documentType = ; // TemplateDocumentType | 

try {
    final response = api.recommendTemplates(documentType);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->recommendTemplates: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentType** | [**TemplateDocumentType**](.md)|  | [optional] 

### Return type

[**BuiltList&lt;TemplateRecord&gt;**](TemplateRecord.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recoverScreenerPassword**
> recoverScreenerPassword(screenerPasswordRecoveryRequest)

Request password recovery for a screener

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final ScreenerPasswordRecoveryRequest screenerPasswordRecoveryRequest = ; // ScreenerPasswordRecoveryRequest | 

try {
    api.recoverScreenerPassword(screenerPasswordRecoveryRequest);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->recoverScreenerPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **screenerPasswordRecoveryRequest** | [**ScreenerPasswordRecoveryRequest**](ScreenerPasswordRecoveryRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **registerScreener**
> ScreenerProfile registerScreener(screenerRegister)

Register a new screener

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final ScreenerRegister screenerRegister = ; // ScreenerRegister | 

try {
    final response = api.registerScreener(screenerRegister);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->registerScreener: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **screenerRegister** | [**ScreenerRegister**](ScreenerRegister.md)|  | 

### Return type

[**ScreenerProfile**](ScreenerProfile.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resendSurveyEmail**
> resendSurveyEmail(responseId)

Resend survey response email

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String responseId = responseId_example; // String | 

try {
    api.resendSurveyEmail(responseId);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->resendSurveyEmail: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **responseId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resolveScreenerAccessLink**
> ScreenerAccessLink resolveScreenerAccessLink(token)

Resolve a prepared screener access link

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String token = token_example; // String | 

try {
    final response = api.resolveScreenerAccessLink(token);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->resolveScreenerAccessLink: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 

### Return type

[**ScreenerAccessLink**](ScreenerAccessLink.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **transcribeVoiceAudio**
> TranscriptionResponse transcribeVoiceAudio(transcriptionRequest)

Transcribe voice audio

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final TranscriptionRequest transcriptionRequest = ; // TranscriptionRequest | 

try {
    final response = api.transcribeVoiceAudio(transcriptionRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->transcribeVoiceAudio: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **transcriptionRequest** | [**TranscriptionRequest**](TranscriptionRequest.md)|  | 

### Return type

[**TranscriptionResponse**](TranscriptionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateAgentAccessPoint**
> AgentAccessPoint updateAgentAccessPoint(accessPointKey, agentAccessPointUpsert)

Update agent access point

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String accessPointKey = accessPointKey_example; // String | 
final AgentAccessPointUpsert agentAccessPointUpsert = ; // AgentAccessPointUpsert | 

try {
    final response = api.updateAgentAccessPoint(accessPointKey, agentAccessPointUpsert);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->updateAgentAccessPoint: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **accessPointKey** | **String**|  | 
 **agentAccessPointUpsert** | [**AgentAccessPointUpsert**](AgentAccessPointUpsert.md)|  | 

### Return type

[**AgentAccessPoint**](AgentAccessPoint.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateChatMessage**
> ChatMessage updateChatMessage(messageId, chatMessageUpdate)

Update chat message

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String messageId = messageId_example; // String | 
final ChatMessageUpdate chatMessageUpdate = ; // ChatMessageUpdate | 

try {
    final response = api.updateChatMessage(messageId, chatMessageUpdate);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->updateChatMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messageId** | **String**|  | 
 **chatMessageUpdate** | [**ChatMessageUpdate**](ChatMessageUpdate.md)|  | 

### Return type

[**ChatMessage**](ChatMessage.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateChatSession**
> ChatSession updateChatSession(sessionId, chatSessionUpdate)

Update chat session

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String sessionId = sessionId_example; // String | 
final ChatSessionUpdate chatSessionUpdate = ; // ChatSessionUpdate | 

try {
    final response = api.updateChatSession(sessionId, chatSessionUpdate);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->updateChatSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  | 
 **chatSessionUpdate** | [**ChatSessionUpdate**](ChatSessionUpdate.md)|  | 

### Return type

[**ChatSession**](ChatSession.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePersonaSkill**
> PersonaSkill updatePersonaSkill(personaSkillKey, personaSkillUpsert)

Update persona skill

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String personaSkillKey = personaSkillKey_example; // String | 
final PersonaSkillUpsert personaSkillUpsert = ; // PersonaSkillUpsert | 

try {
    final response = api.updatePersonaSkill(personaSkillKey, personaSkillUpsert);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->updatePersonaSkill: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **personaSkillKey** | **String**|  | 
 **personaSkillUpsert** | [**PersonaSkillUpsert**](PersonaSkillUpsert.md)|  | 

### Return type

[**PersonaSkill**](PersonaSkill.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateSurvey**
> Survey updateSurvey(surveyId, survey)

Update survey

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String surveyId = surveyId_example; // String | 
final Survey survey = ; // Survey | 

try {
    final response = api.updateSurvey(surveyId, survey);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->updateSurvey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **surveyId** | **String**|  | 
 **survey** | [**Survey**](Survey.md)|  | 

### Return type

[**Survey**](Survey.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateSurveyPrompt**
> SurveyPrompt updateSurveyPrompt(promptKey, surveyPromptUpsert)

Update reusable survey prompt

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String promptKey = promptKey_example; // String | 
final SurveyPromptUpsert surveyPromptUpsert = ; // SurveyPromptUpsert | 

try {
    final response = api.updateSurveyPrompt(promptKey, surveyPromptUpsert);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->updateSurveyPrompt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **promptKey** | **String**|  | 
 **surveyPromptUpsert** | [**SurveyPromptUpsert**](SurveyPromptUpsert.md)|  | 

### Return type

[**SurveyPrompt**](SurveyPrompt.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateTemplate**
> TemplateRecord updateTemplate(templateId, templateUpdateRequest)

Update template (new version)

### Example
```dart
import 'package:survey_backend_api/api.dart';

final api = SurveyBackendApi().getDefaultApi();
final String templateId = templateId_example; // String | 
final TemplateUpdateRequest templateUpdateRequest = ; // TemplateUpdateRequest | 

try {
    final response = api.updateTemplate(templateId, templateUpdateRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->updateTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **templateId** | **String**|  | 
 **templateUpdateRequest** | [**TemplateUpdateRequest**](TemplateUpdateRequest.md)|  | 

### Return type

[**TemplateRecord**](TemplateRecord.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

