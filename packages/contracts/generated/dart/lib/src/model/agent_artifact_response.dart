//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/agent_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:survey_backend_api/src/model/ai_progress.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'agent_artifact_response.g.dart';

/// AgentArtifactResponse
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
/// * [accessPointKey] 
@BuiltValue()
abstract class AgentArtifactResponse implements AgentResponse, Built<AgentArtifactResponse, AgentArtifactResponseBuilder> {
  @BuiltValueField(wireName: r'accessPointKey')
  String? get accessPointKey;

  AgentArtifactResponse._();

  factory AgentArtifactResponse([void updates(AgentArtifactResponseBuilder b)]) = _$AgentArtifactResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AgentArtifactResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AgentArtifactResponse> get serializer => _$AgentArtifactResponseSerializer();
}

class _$AgentArtifactResponseSerializer implements PrimitiveSerializer<AgentArtifactResponse> {
  @override
  final Iterable<Type> types = const [AgentArtifactResponse, _$AgentArtifactResponse];

  @override
  final String wireName = r'AgentArtifactResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AgentArtifactResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.personaSkillVersion != null) {
      yield r'persona_skill_version';
      yield serializers.serialize(
        object.personaSkillVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.aiProgress != null) {
      yield r'aiProgress';
      yield serializers.serialize(
        object.aiProgress,
        specifiedType: const FullType(AIProgress),
      );
    }
    if (object.modelVersion != null) {
      yield r'model_version';
      yield serializers.serialize(
        object.modelVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.questionnairePromptVersion != null) {
      yield r'questionnaire_prompt_version';
      yield serializers.serialize(
        object.questionnairePromptVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.warnings != null) {
      yield r'warnings';
      yield serializers.serialize(
        object.warnings,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.medicalRecord != null) {
      yield r'medicalRecord';
      yield serializers.serialize(
        object.medicalRecord,
        specifiedType: const FullType(String),
      );
    }
    if (object.errorMessage != null) {
      yield r'errorMessage';
      yield serializers.serialize(
        object.errorMessage,
        specifiedType: const FullType(String),
      );
    }
    if (object.classification != null) {
      yield r'classification';
      yield serializers.serialize(
        object.classification,
        specifiedType: const FullType(String),
      );
    }
    if (object.accessPointKey != null) {
      yield r'accessPointKey';
      yield serializers.serialize(
        object.accessPointKey,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.promptVersion != null) {
      yield r'prompt_version';
      yield serializers.serialize(
        object.promptVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.report != null) {
      yield r'report';
      yield serializers.serialize(
        object.report,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.inputType != null) {
      yield r'input_type';
      yield serializers.serialize(
        object.inputType,
        specifiedType: const FullType(String),
      );
    }
    if (object.ok != null) {
      yield r'ok';
      yield serializers.serialize(
        object.ok,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AgentArtifactResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AgentArtifactResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'persona_skill_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.personaSkillVersion = valueDes;
          break;
        case r'aiProgress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AIProgress),
          ) as AIProgress;
          result.aiProgress.replace(valueDes);
          break;
        case r'model_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.modelVersion = valueDes;
          break;
        case r'questionnaire_prompt_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.questionnairePromptVersion = valueDes;
          break;
        case r'warnings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.warnings.replace(valueDes);
          break;
        case r'medicalRecord':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.medicalRecord = valueDes;
          break;
        case r'errorMessage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.errorMessage = valueDes;
          break;
        case r'classification':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.classification = valueDes;
          break;
        case r'accessPointKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.accessPointKey = valueDes;
          break;
        case r'prompt_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.promptVersion = valueDes;
          break;
        case r'report':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.report = valueDes;
          break;
        case r'input_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.inputType = valueDes;
          break;
        case r'ok':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.ok = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AgentArtifactResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AgentArtifactResponseBuilder();
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

