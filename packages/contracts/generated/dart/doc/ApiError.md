# survey_backend_api.model.ApiError

## Load the model package
```dart
import 'package:survey_backend_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**code** | **String** | Stable string identifier for the error category | 
**userMessage** | **String** | Localized, human-readable message in pt-BR | 
**severity** | **String** |  | [optional] [default to 'error']
**retryable** | **bool** |  | [optional] [default to false]
**requestId** | **String** |  | [optional] 
**operation** | **String** |  | [optional] 
**stage** | **String** |  | [optional] 
**details** | [**BuiltList&lt;JsonObject&gt;**](JsonObject.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


