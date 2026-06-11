//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ai_agent_upsert.g.dart';

/// AIAgentUpsert
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
@BuiltValue(instantiable: false)
abstract class AIAgentUpsert  {
  @BuiltValueField(wireName: r'agentKey')
  String get agentKey;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'providerType')
  AIAgentUpsertProviderTypeEnum get providerType;
  // enum providerTypeEnum {  openai_compatible,  glm,  gemini,  };

  @BuiltValueField(wireName: r'baseUrl')
  String? get baseUrl;

  @BuiltValueField(wireName: r'apiKeyEnvVar')
  String get apiKeyEnvVar;

  @BuiltValueField(wireName: r'defaultModel')
  String get defaultModel;

  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  @BuiltValueField(wireName: r'supportsOpenAIChatCompletions')
  bool? get supportsOpenAIChatCompletions;

  @BuiltValueField(wireName: r'supportsResponseFormat')
  bool? get supportsResponseFormat;

  @BuiltValueField(wireName: r'supportsRag')
  bool? get supportsRag;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueSerializer(custom: true)
  static Serializer<AIAgentUpsert> get serializer => _$AIAgentUpsertSerializer();
}

class _$AIAgentUpsertSerializer implements PrimitiveSerializer<AIAgentUpsert> {
  @override
  final Iterable<Type> types = const [AIAgentUpsert];

  @override
  final String wireName = r'AIAgentUpsert';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AIAgentUpsert object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'agentKey';
    yield serializers.serialize(
      object.agentKey,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'providerType';
    yield serializers.serialize(
      object.providerType,
      specifiedType: const FullType(AIAgentUpsertProviderTypeEnum),
    );
    if (object.baseUrl != null) {
      yield r'baseUrl';
      yield serializers.serialize(
        object.baseUrl,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'apiKeyEnvVar';
    yield serializers.serialize(
      object.apiKeyEnvVar,
      specifiedType: const FullType(String),
    );
    yield r'defaultModel';
    yield serializers.serialize(
      object.defaultModel,
      specifiedType: const FullType(String),
    );
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.supportsOpenAIChatCompletions != null) {
      yield r'supportsOpenAIChatCompletions';
      yield serializers.serialize(
        object.supportsOpenAIChatCompletions,
        specifiedType: const FullType(bool),
      );
    }
    if (object.supportsResponseFormat != null) {
      yield r'supportsResponseFormat';
      yield serializers.serialize(
        object.supportsResponseFormat,
        specifiedType: const FullType(bool),
      );
    }
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
  }

  @override
  Object serialize(
    Serializers serializers,
    AIAgentUpsert object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  AIAgentUpsert deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($AIAgentUpsert)) as $AIAgentUpsert;
  }
}

/// a concrete implementation of [AIAgentUpsert], since [AIAgentUpsert] is not instantiable
@BuiltValue(instantiable: true)
abstract class $AIAgentUpsert implements AIAgentUpsert, Built<$AIAgentUpsert, $AIAgentUpsertBuilder> {
  $AIAgentUpsert._();

  factory $AIAgentUpsert([void Function($AIAgentUpsertBuilder)? updates]) = _$$AIAgentUpsert;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($AIAgentUpsertBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$AIAgentUpsert> get serializer => _$$AIAgentUpsertSerializer();
}

class _$$AIAgentUpsertSerializer implements PrimitiveSerializer<$AIAgentUpsert> {
  @override
  final Iterable<Type> types = const [$AIAgentUpsert, _$$AIAgentUpsert];

  @override
  final String wireName = r'$AIAgentUpsert';

  @override
  Object serialize(
    Serializers serializers,
    $AIAgentUpsert object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(AIAgentUpsert))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AIAgentUpsertBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'agentKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.agentKey = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'providerType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AIAgentUpsertProviderTypeEnum),
          ) as AIAgentUpsertProviderTypeEnum;
          result.providerType = valueDes;
          break;
        case r'baseUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.baseUrl = valueDes;
          break;
        case r'apiKeyEnvVar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.apiKeyEnvVar = valueDes;
          break;
        case r'defaultModel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.defaultModel = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        case r'supportsOpenAIChatCompletions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.supportsOpenAIChatCompletions = valueDes;
          break;
        case r'supportsResponseFormat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.supportsResponseFormat = valueDes;
          break;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  $AIAgentUpsert deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $AIAgentUpsertBuilder();
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

class AIAgentUpsertProviderTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'openai_compatible')
  static const AIAgentUpsertProviderTypeEnum openaiCompatible = _$aIAgentUpsertProviderTypeEnum_openaiCompatible;
  @BuiltValueEnumConst(wireName: r'glm')
  static const AIAgentUpsertProviderTypeEnum glm = _$aIAgentUpsertProviderTypeEnum_glm;
  @BuiltValueEnumConst(wireName: r'gemini')
  static const AIAgentUpsertProviderTypeEnum gemini = _$aIAgentUpsertProviderTypeEnum_gemini;

  static Serializer<AIAgentUpsertProviderTypeEnum> get serializer => _$aIAgentUpsertProviderTypeEnumSerializer;

  const AIAgentUpsertProviderTypeEnum._(String name): super(name);

  static BuiltSet<AIAgentUpsertProviderTypeEnum> get values => _$aIAgentUpsertProviderTypeEnumValues;
  static AIAgentUpsertProviderTypeEnum valueOf(String name) => _$aIAgentUpsertProviderTypeEnumValueOf(name);
}

