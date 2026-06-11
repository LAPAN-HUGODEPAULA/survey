//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/ai_agent_route_ref.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ai_config.g.dart';

/// AIConfig
///
/// Properties:
/// * [agentRefs] 
/// * [primaryProvider] 
/// * [primaryModel] 
/// * [fallbackProvider] 
/// * [fallbackModel] 
/// * [temperature] 
/// * [reasoningEffort] 
/// * [enableCaching] 
@BuiltValue()
abstract class AIConfig implements Built<AIConfig, AIConfigBuilder> {
  @BuiltValueField(wireName: r'agentRefs')
  BuiltList<AIAgentRouteRef>? get agentRefs;

  @BuiltValueField(wireName: r'primaryProvider')
  String? get primaryProvider;

  @BuiltValueField(wireName: r'primaryModel')
  String? get primaryModel;

  @BuiltValueField(wireName: r'fallbackProvider')
  String? get fallbackProvider;

  @BuiltValueField(wireName: r'fallbackModel')
  String? get fallbackModel;

  @BuiltValueField(wireName: r'temperature')
  double? get temperature;

  @BuiltValueField(wireName: r'reasoningEffort')
  AIConfigReasoningEffortEnum? get reasoningEffort;
  // enum reasoningEffortEnum {  low,  medium,  high,  };

  @BuiltValueField(wireName: r'enableCaching')
  bool? get enableCaching;

  AIConfig._();

  factory AIConfig([void updates(AIConfigBuilder b)]) = _$AIConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AIConfigBuilder b) => b
      ..temperature = 0.0
      ..reasoningEffort = const AIConfigReasoningEffortEnum._('low')
      ..enableCaching = true;

  @BuiltValueSerializer(custom: true)
  static Serializer<AIConfig> get serializer => _$AIConfigSerializer();
}

class _$AIConfigSerializer implements PrimitiveSerializer<AIConfig> {
  @override
  final Iterable<Type> types = const [AIConfig, _$AIConfig];

  @override
  final String wireName = r'AIConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AIConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.agentRefs != null) {
      yield r'agentRefs';
      yield serializers.serialize(
        object.agentRefs,
        specifiedType: const FullType.nullable(BuiltList, [FullType(AIAgentRouteRef)]),
      );
    }
    if (object.primaryProvider != null) {
      yield r'primaryProvider';
      yield serializers.serialize(
        object.primaryProvider,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.primaryModel != null) {
      yield r'primaryModel';
      yield serializers.serialize(
        object.primaryModel,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.fallbackProvider != null) {
      yield r'fallbackProvider';
      yield serializers.serialize(
        object.fallbackProvider,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.fallbackModel != null) {
      yield r'fallbackModel';
      yield serializers.serialize(
        object.fallbackModel,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.temperature != null) {
      yield r'temperature';
      yield serializers.serialize(
        object.temperature,
        specifiedType: const FullType(double),
      );
    }
    if (object.reasoningEffort != null) {
      yield r'reasoningEffort';
      yield serializers.serialize(
        object.reasoningEffort,
        specifiedType: const FullType.nullable(AIConfigReasoningEffortEnum),
      );
    }
    if (object.enableCaching != null) {
      yield r'enableCaching';
      yield serializers.serialize(
        object.enableCaching,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AIConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AIConfigBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'agentRefs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(AIAgentRouteRef)]),
          ) as BuiltList<AIAgentRouteRef>?;
          if (valueDes == null) continue;
          result.agentRefs.replace(valueDes);
          break;
        case r'primaryProvider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.primaryProvider = valueDes;
          break;
        case r'primaryModel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.primaryModel = valueDes;
          break;
        case r'fallbackProvider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fallbackProvider = valueDes;
          break;
        case r'fallbackModel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fallbackModel = valueDes;
          break;
        case r'temperature':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.temperature = valueDes;
          break;
        case r'reasoningEffort':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(AIConfigReasoningEffortEnum),
          ) as AIConfigReasoningEffortEnum?;
          if (valueDes == null) continue;
          result.reasoningEffort = valueDes;
          break;
        case r'enableCaching':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enableCaching = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AIConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AIConfigBuilder();
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

class AIConfigReasoningEffortEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'low')
  static const AIConfigReasoningEffortEnum low = _$aIConfigReasoningEffortEnum_low;
  @BuiltValueEnumConst(wireName: r'medium')
  static const AIConfigReasoningEffortEnum medium = _$aIConfigReasoningEffortEnum_medium;
  @BuiltValueEnumConst(wireName: r'high')
  static const AIConfigReasoningEffortEnum high = _$aIConfigReasoningEffortEnum_high;

  static Serializer<AIConfigReasoningEffortEnum> get serializer => _$aIConfigReasoningEffortEnumSerializer;

  const AIConfigReasoningEffortEnum._(String name): super(name);

  static BuiltSet<AIConfigReasoningEffortEnum> get values => _$aIConfigReasoningEffortEnumValues;
  static AIConfigReasoningEffortEnum valueOf(String name) => _$aIConfigReasoningEffortEnumValueOf(name);
}

