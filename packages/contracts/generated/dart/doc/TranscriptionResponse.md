# survey_backend_api.model.TranscriptionResponse

## Load the model package
```dart
import 'package:survey_backend_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**requestId** | **String** |  | 
**text** | **String** |  | 
**confidence** | **double** |  | [optional] 
**segments** | [**BuiltList&lt;TranscriptionSegment&gt;**](TranscriptionSegment.md) |  | [optional] 
**processingTimeMs** | **int** |  | 
**provider** | **String** |  | 
**language** | **String** |  | 
**warnings** | **BuiltList&lt;String&gt;** |  | [optional] 
**metadata** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


