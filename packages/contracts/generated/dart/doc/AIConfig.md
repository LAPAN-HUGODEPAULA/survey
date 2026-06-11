# survey_backend_api.model.AIConfig

## Load the model package
```dart
import 'package:survey_backend_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**agentRefs** | [**BuiltList&lt;AIAgentRouteRef&gt;**](AIAgentRouteRef.md) |  | [optional] 
**primaryProvider** | **String** |  | [optional] 
**primaryModel** | **String** |  | [optional] 
**fallbackProvider** | **String** |  | [optional] 
**fallbackModel** | **String** |  | [optional] 
**temperature** | **double** |  | [optional] [default to 0.0]
**reasoningEffort** | **String** |  | [optional] [default to 'low']
**enableCaching** | **bool** |  | [optional] [default to true]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


