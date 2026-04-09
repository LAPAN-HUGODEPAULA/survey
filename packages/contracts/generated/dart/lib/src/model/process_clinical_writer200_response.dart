//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/agent_response.dart';
import 'package:survey_backend_api/src/model/clinical_writer_task_error.dart';
import 'package:built_collection/built_collection.dart';
import 'package:survey_backend_api/src/model/ai_progress.dart';
import 'package:survey_backend_api/src/model/clinical_writer_task_response.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'process_clinical_writer200_response.g.dart';

/// ProcessClinicalWriter200Response
///
/// Properties:
/// * [ok] 
/// * [inputType] 
/// * [promptVersion] 
/// * [questionnairePromptVersion] 
/// * [personaSkillVersion] 
/// * [modelVersion] 
/// * [report] 
/// * [warnings] 
/// * [classification] 
/// * [medicalRecord] 
/// * [errorMessage] 
/// * [aiProgress] 
/// * [taskId] 
/// * [status] 
/// * [result] 
/// * [error] 
@BuiltValue()
abstract class ProcessClinicalWriter200Response implements Built<ProcessClinicalWriter200Response, ProcessClinicalWriter200ResponseBuilder> {
  /// One Of [AgentResponse], [ClinicalWriterTaskResponse]
  OneOf get oneOf;

  ProcessClinicalWriter200Response._();

  factory ProcessClinicalWriter200Response([void updates(ProcessClinicalWriter200ResponseBuilder b)]) = _$ProcessClinicalWriter200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProcessClinicalWriter200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProcessClinicalWriter200Response> get serializer => _$ProcessClinicalWriter200ResponseSerializer();
}

class _$ProcessClinicalWriter200ResponseSerializer implements PrimitiveSerializer<ProcessClinicalWriter200Response> {
  @override
  final Iterable<Type> types = const [ProcessClinicalWriter200Response, _$ProcessClinicalWriter200Response];

  @override
  final String wireName = r'ProcessClinicalWriter200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProcessClinicalWriter200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    ProcessClinicalWriter200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  ProcessClinicalWriter200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProcessClinicalWriter200ResponseBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [FullType(AgentResponse), FullType(ClinicalWriterTaskResponse), ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc, specifiedType: targetType) as OneOf;
    return result.build();
  }
}

