//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/agent_response.dart';
import 'package:survey_backend_api/src/model/clinical_writer_task_error.dart';
import 'package:survey_backend_api/src/model/ai_progress.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'clinical_writer_task_response.g.dart';

/// ClinicalWriterTaskResponse
///
/// Properties:
/// * [taskId] 
/// * [status] 
/// * [aiProgress] 
/// * [result] 
/// * [error] 
@BuiltValue()
abstract class ClinicalWriterTaskResponse implements Built<ClinicalWriterTaskResponse, ClinicalWriterTaskResponseBuilder> {
  @BuiltValueField(wireName: r'taskId')
  String get taskId;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'aiProgress')
  AIProgress get aiProgress;

  @BuiltValueField(wireName: r'result')
  AgentResponse? get result;

  @BuiltValueField(wireName: r'error')
  ClinicalWriterTaskError? get error;

  ClinicalWriterTaskResponse._();

  factory ClinicalWriterTaskResponse([void updates(ClinicalWriterTaskResponseBuilder b)]) = _$ClinicalWriterTaskResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClinicalWriterTaskResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClinicalWriterTaskResponse> get serializer => _$ClinicalWriterTaskResponseSerializer();
}

class _$ClinicalWriterTaskResponseSerializer implements PrimitiveSerializer<ClinicalWriterTaskResponse> {
  @override
  final Iterable<Type> types = const [ClinicalWriterTaskResponse, _$ClinicalWriterTaskResponse];

  @override
  final String wireName = r'ClinicalWriterTaskResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClinicalWriterTaskResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'taskId';
    yield serializers.serialize(
      object.taskId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'aiProgress';
    yield serializers.serialize(
      object.aiProgress,
      specifiedType: const FullType(AIProgress),
    );
    if (object.result != null) {
      yield r'result';
      yield serializers.serialize(
        object.result,
        specifiedType: const FullType(AgentResponse),
      );
    }
    if (object.error != null) {
      yield r'error';
      yield serializers.serialize(
        object.error,
        specifiedType: const FullType(ClinicalWriterTaskError),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ClinicalWriterTaskResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClinicalWriterTaskResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'taskId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.taskId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'aiProgress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AIProgress),
          ) as AIProgress;
          result.aiProgress.replace(valueDes);
          break;
        case r'result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AgentResponse),
          ) as AgentResponse;
          result.result.replace(valueDes);
          break;
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ClinicalWriterTaskError),
          ) as ClinicalWriterTaskError;
          result.error.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClinicalWriterTaskResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClinicalWriterTaskResponseBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

