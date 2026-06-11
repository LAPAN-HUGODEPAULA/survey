//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:survey_backend_api/src/model/ai_agent_upsert.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ai_agent.g.dart';

/// AIAgent
///
/// Properties:
/// * [agentKey] 
/// * [name] 
/// * [providerType] 
/// * [baseUrl] 
/// * [apiKeyEnvVar] 
/// * [defaultModel] 
/// * [enabled] 
/// * [supportsOpenAIChatCompletions] 
/// * [supportsResponseFormat] 
/// * [supportsRag] 
/// * [notes] 
/// * [createdAt] 
/// * [modifiedAt] 
@BuiltValue()
abstract class AIAgent implements AIAgentUpsert, Built<AIAgent, AIAgentBuilder> {
  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'modifiedAt')
  DateTime get modifiedAt;

  AIAgent._();

  factory AIAgent([void updates(AIAgentBuilder b)]) = _$AIAgent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AIAgentBuilder b) => b
      ..supportsRag = false
      ..supportsResponseFormat = false
      ..enabled = true
      ..supportsOpenAIChatCompletions = true;

  @BuiltValueSerializer(custom: true)
  static Serializer<AIAgent> get serializer => _$AIAgentSerializer();
}

class _$AIAgentSerializer implements PrimitiveSerializer<AIAgent> {
  @override
  final Iterable<Type> types = const [AIAgent, _$AIAgent];

  @override
  final String wireName = r'AIAgent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AIAgent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.supportsRag != null) {
      yield r'supportsRag';
      yield serializers.serialize(
        object.supportsRag,
        specifiedType: const FullType(bool),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'modifiedAt';
    yield serializers.serialize(
      object.modifiedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.supportsResponseFormat != null) {
      yield r'supportsResponseFormat';
      yield serializers.serialize(
        object.supportsResponseFormat,
        specifiedType: const FullType(bool),
      );
    }
    yield r'apiKeyEnvVar';
    yield serializers.serialize(
      object.apiKeyEnvVar,
      specifiedType: const FullType(String),
    );
    yield r'agentKey';
    yield serializers.serialize(
      object.agentKey,
      specifiedType: const FullType(String),
    );
    yield r'providerType';
    yield serializers.serialize(
      object.providerType,
      specifiedType: const FullType(AIAgentUpsertProviderTypeEnum),
    );
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType(bool),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.baseUrl != null) {
      yield r'baseUrl';
      yield serializers.serialize(
        object.baseUrl,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.supportsOpenAIChatCompletions != null) {
      yield r'supportsOpenAIChatCompletions';
      yield serializers.serialize(
        object.supportsOpenAIChatCompletions,
        specifiedType: const FullType(bool),
      );
    }
    yield r'defaultModel';
    yield serializers.serialize(
      object.defaultModel,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AIAgent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AIAgentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'supportsRag':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.supportsRag = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'modifiedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.modifiedAt = valueDes;
          break;
        case r'supportsResponseFormat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.supportsResponseFormat = valueDes;
          break;
        case r'apiKeyEnvVar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.apiKeyEnvVar = valueDes;
          break;
        case r'agentKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.agentKey = valueDes;
          break;
        case r'providerType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AIAgentUpsertProviderTypeEnum),
          ) as AIAgentUpsertProviderTypeEnum;
          result.providerType = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'baseUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.baseUrl = valueDes;
          break;
        case r'supportsOpenAIChatCompletions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.supportsOpenAIChatCompletions = valueDes;
          break;
        case r'defaultModel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.defaultModel = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AIAgent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AIAgentBuilder();
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

class AIAgentProviderTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'openai_compatible')
  static const AIAgentProviderTypeEnum openaiCompatible = _$aIAgentProviderTypeEnum_openaiCompatible;
  @BuiltValueEnumConst(wireName: r'glm')
  static const AIAgentProviderTypeEnum glm = _$aIAgentProviderTypeEnum_glm;
  @BuiltValueEnumConst(wireName: r'gemini')
  static const AIAgentProviderTypeEnum gemini = _$aIAgentProviderTypeEnum_gemini;

  static Serializer<AIAgentProviderTypeEnum> get serializer => _$aIAgentProviderTypeEnumSerializer;

  const AIAgentProviderTypeEnum._(String name): super(name);

  static BuiltSet<AIAgentProviderTypeEnum> get values => _$aIAgentProviderTypeEnumValues;
  static AIAgentProviderTypeEnum valueOf(String name) => _$aIAgentProviderTypeEnumValueOf(name);
}

