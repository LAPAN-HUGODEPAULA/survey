# survey_backend_api.api.DefaultApi

## Load the API package
```dart
import 'package:survey_backend_api/api.dart';
```

All URIs are relative to *http://localhost:8000/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createPatientResponse**](DefaultApi.md#createpatientresponse) | **POST** /patient_responses/ | Create patient response
[**createSurvey**](DefaultApi.md#createsurvey) | **POST** /surveys/ | Create survey
[**createSurveyResponse**](DefaultApi.md#createsurveyresponse) | **POST** /survey_responses/ | Create survey response
[**getSurvey**](DefaultApi.md#getsurvey) | **GET** /surveys/{surveyId} | Get survey by id
[**getSurveyResponse**](DefaultApi.md#getsurveyresponse) | **GET** /survey_responses/{responseId} | Get survey response by id
[**listSurveyResponses**](DefaultApi.md#listsurveyresponses) | **GET** /survey_responses/ | List survey responses
[**listSurveys**](DefaultApi.md#listsurveys) | **GET** /surveys/ | List surveys
[**resendSurveyEmail**](DefaultApi.md#resendsurveyemail) | **POST** /survey_responses/{responseId}/send_email | Resend survey response email


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

