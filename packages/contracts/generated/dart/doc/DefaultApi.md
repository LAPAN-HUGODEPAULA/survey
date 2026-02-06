# survey_backend_api.api.DefaultApi

## Load the API package
```dart
import 'package:survey_backend_api/api.dart';
```

All URIs are relative to **

Method | HTTP request | Description
------------- | ------------- | -------------
[**analyzeClinicalWriter**](DefaultApi.md#analyzeclinicalwriter) | **POST** /clinical_writer/analysis | Analyze conversation context with Clinical Writer
[**approveTemplate**](DefaultApi.md#approvetemplate) | **POST** /templates/{templateId}/approve | Approve template
[**archiveTemplate**](DefaultApi.md#archivetemplate) | **POST** /templates/{templateId}/archive | Archive template
[**completeChatSession**](DefaultApi.md#completechatsession) | **POST** /chat/sessions/{sessionId}/complete | Complete chat session
[**createChatMessage**](DefaultApi.md#createchatmessage) | **POST** /chat/sessions/{sessionId}/messages | Create chat message
[**createChatSession**](DefaultApi.md#createchatsession) | **POST** /chat/sessions | Create chat session
[**createPatientResponse**](DefaultApi.md#createpatientresponse) | **POST** /patient_responses/ | Create patient response
[**createSurvey**](DefaultApi.md#createsurvey) | **POST** /surveys/ | Create survey
[**createSurveyResponse**](DefaultApi.md#createsurveyresponse) | **POST** /survey_responses/ | Create survey response
[**createTemplate**](DefaultApi.md#createtemplate) | **POST** /templates | Create template
[**deleteSurvey**](DefaultApi.md#deletesurvey) | **DELETE** /surveys/{surveyId} | Delete survey
[**exportDocument**](DefaultApi.md#exportdocument) | **POST** /documents/export | Export document
[**getChatSession**](DefaultApi.md#getchatsession) | **GET** /chat/sessions/{sessionId} | Get chat session
[**getCurrentScreener**](DefaultApi.md#getcurrentscreener) | **GET** /screeners/me | Get the current screener profile
[**getDocument**](DefaultApi.md#getdocument) | **GET** /documents/{documentId} | Get document record
[**getSurvey**](DefaultApi.md#getsurvey) | **GET** /surveys/{surveyId} | Get survey by id
[**getSurveyResponse**](DefaultApi.md#getsurveyresponse) | **GET** /survey_responses/{responseId} | Get survey response by id
[**getTemplate**](DefaultApi.md#gettemplate) | **GET** /templates/{templateId} | Get template
[**listChatMessages**](DefaultApi.md#listchatmessages) | **GET** /chat/sessions/{sessionId}/messages | List chat messages
[**listChatSessions**](DefaultApi.md#listchatsessions) | **GET** /chat/sessions | List chat sessions
[**listSurveyResponses**](DefaultApi.md#listsurveyresponses) | **GET** /survey_responses/ | List survey responses
[**listSurveys**](DefaultApi.md#listsurveys) | **GET** /surveys/ | List surveys
[**listTemplateDocumentTypes**](DefaultApi.md#listtemplatedocumenttypes) | **GET** /templates/document-types | List supported template document types
[**listTemplates**](DefaultApi.md#listtemplates) | **GET** /templates | List templates
[**loginScreener**](DefaultApi.md#loginscreener) | **POST** /screeners/login | Authenticate a screener and get an access token
[**previewDocument**](DefaultApi.md#previewdocument) | **POST** /documents/preview | Generate document preview
[**previewTemplate**](DefaultApi.md#previewtemplate) | **POST** /templates/{templateId}/preview | Preview template
[**processClinicalWriter**](DefaultApi.md#processclinicalwriter) | **POST** /clinical_writer/process | Forward content to Clinical Writer
[**recommendTemplates**](DefaultApi.md#recommendtemplates) | **GET** /templates/recommendations | Recommend templates
[**recoverScreenerPassword**](DefaultApi.md#recoverscreenerpassword) | **POST** /screeners/recover-password | Request password recovery for a screener
[**registerScreener**](DefaultApi.md#registerscreener) | **POST** /screeners/register | Register a new screener
[**resendSurveyEmail**](DefaultApi.md#resendsurveyemail) | **POST** /survey_responses/{responseId}/send_email | Resend survey response email
[**transcribeVoiceAudio**](DefaultApi.md#transcribevoiceaudio) | **POST** /voice/transcriptions | Transcribe voice audio
[**updateChatMessage**](DefaultApi.md#updatechatmessage) | **PATCH** /chat/messages/{messageId} | Update chat message
[**updateChatSession**](DefaultApi.md#updatechatsession) | **PATCH** /chat/sessions/{sessionId} | Update chat session
[**updateSurvey**](DefaultApi.md#updatesurvey) | **PUT** /surveys/{surveyId} | Update survey
[**updateTemplate**](DefaultApi.md#updatetemplate) | **PUT** /templates/{templateId} | Update template (new version)


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
> AgentResponse processClinicalWriter(clinicalWriterRequest)

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

[**AgentResponse**](AgentResponse.md)

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

