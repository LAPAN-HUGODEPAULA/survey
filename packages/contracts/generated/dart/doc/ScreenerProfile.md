# survey_backend_api.model.ScreenerProfile

## Load the model package
```dart
import 'package:survey_backend_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**cpf** | **String** | CPF do Screener | 
**firstName** | **String** | Primeiro nome do Screener | 
**surname** | **String** | Sobrenome do Screener | 
**email** | **String** | Endereço de e-mail do Screener | 
**phone** | **String** | Número de telefone do Screener | 
**address** | [**Address**](Address.md) |  | 
**professionalCouncil** | [**ProfessionalCouncil**](ProfessionalCouncil.md) |  | 
**jobTitle** | **String** | Cargo/profissão do Screener | 
**degree** | **String** | Formação acadêmica/grau do Screener | 
**isBuilderAdmin** | **bool** | Indica se o screener pode acessar o construtor administrativo | [optional] [default to false]
**darvCourseYear** | **int** | Ano de conclusão do curso DARV (opcional) | [optional] 
**initialNoticeAcceptedAt** | [**DateTime**](DateTime.md) | Data de aceite do aviso inicial de uso da plataforma | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


