# survey_backend_api.model.SurveyResponseWithAgent

## Load the model package
```dart
import 'package:survey_backend_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | [optional] 
**surveyId** | **String** |  | 
**creatorName** | **String** |  | [optional] 
**creatorContact** | **String** |  | [optional] 
**testDate** | [**DateTime**](DateTime.md) |  | [optional] 
**screenerName** | **String** |  | [optional] 
**screenerEmail** | **String** |  | [optional] 
**patient** | [**Patient**](Patient.md) |  | 
**answers** | [**BuiltList&lt;Answer&gt;**](Answer.md) |  | 
**agentResponse** | [**AgentResponse**](AgentResponse.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


