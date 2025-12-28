//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/patient.dart';
import 'package:survey_backend_api/src/model/answer.dart';
import 'package:survey_backend_api/src/model/survey_response.dart';
import 'package:survey_backend_api/src/model/agent_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'survey_response_with_agent.g.dart';

/// SurveyResponseWithAgent
///
/// Properties:
/// * [id] 
/// * [id] 
/// * [surveyId] 
/// * [patient] 
/// * [answers] 
/// * [notes] 
/// * [agentResponse] 
@BuiltValue()
abstract class SurveyResponseWithAgent implements SurveyResponse, Built<SurveyResponseWithAgent, SurveyResponseWithAgentBuilder> {
  @BuiltValueField(wireName: r'agent_response')
  AgentResponse? get agentResponse;

  SurveyResponseWithAgent._();

  factory SurveyResponseWithAgent([void updates(SurveyResponseWithAgentBuilder b)]) = _$SurveyResponseWithAgent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SurveyResponseWithAgentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SurveyResponseWithAgent> get serializer => _$SurveyResponseWithAgentSerializer();
}

class _$SurveyResponseWithAgentSerializer implements PrimitiveSerializer<SurveyResponseWithAgent> {
  @override
  final Iterable<Type> types = const [SurveyResponseWithAgent, _$SurveyResponseWithAgent];

  @override
  final String wireName = r'SurveyResponseWithAgent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SurveyResponseWithAgent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'answers';
    yield serializers.serialize(
      object.answers,
      specifiedType: const FullType(BuiltList, [FullType(Answer)]),
    );
    yield r'surveyId';
    yield serializers.serialize(
      object.surveyId,
      specifiedType: const FullType(String),
    );
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.agentResponse != null) {
      yield r'agent_response';
      yield serializers.serialize(
        object.agentResponse,
        specifiedType: const FullType(AgentResponse),
      );
    }
    yield r'patient';
    yield serializers.serialize(
      object.patient,
      specifiedType: const FullType(Patient),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SurveyResponseWithAgent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SurveyResponseWithAgentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'answers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Answer)]),
          ) as BuiltList<Answer>;
          result.answers.replace(valueDes);
          break;
        case r'surveyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.surveyId = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.notes = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'agent_response':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AgentResponse),
          ) as AgentResponse;
          result.agentResponse.replace(valueDes);
          break;
        case r'patient':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Patient),
          ) as Patient;
          result.patient.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SurveyResponseWithAgent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SurveyResponseWithAgentBuilder();
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

