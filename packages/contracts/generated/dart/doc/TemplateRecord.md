# survey_backend_api.model.TemplateRecord

## Load the model package
```dart
import 'package:survey_backend_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | [optional] 
**templateGroupId** | **String** |  | [optional] 
**name** | **String** |  | 
**documentType** | [**TemplateDocumentType**](TemplateDocumentType.md) |  | 
**version** | **String** |  | 
**status** | **String** |  | 
**body** | **String** |  | 
**placeholders** | **BuiltList&lt;String&gt;** |  | 
**conditions** | [**BuiltList&lt;JsonObject&gt;**](JsonObject.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 
**approvedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**createdBy** | **String** |  | [optional] 
**updatedBy** | **String** |  | [optional] 
**approvedBy** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


