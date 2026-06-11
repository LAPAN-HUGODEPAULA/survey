//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ai_agent_route_ref.g.dart';

/// AIAgentRouteRef
///
/// Properties:
/// * [agentKey] 
/// * [model] 
/// * [temperature] 
/// * [maxTokens] 
/// * [enabled] 
@BuiltValue()
abstract class AIAgentRouteRef implements Built<AIAgentRouteRef, AIAgentRouteRefBuilder> {
  @BuiltValueField(wireName: r'agentKey')
  String get agentKey;

  @BuiltValueField(wireName: r'model')
  String? get model;

  @BuiltValueField(wireName: r'temperature')
  double? get temperature;

  @BuiltValueField(wireName: r'maxTokens')
  int? get maxTokens;

  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  AIAgentRouteRef._();

  factory AIAgentRouteRef([void updates(AIAgentRouteRefBuilder b)]) = _$AIAgentRouteRef;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AIAgentRouteRefBuilder b) => b
      ..enabled = true;

  @BuiltValueSerializer(custom: true)
  static Serializer<AIAgentRouteRef> get serializer => _$AIAgentRouteRefSerializer();
}

class _$AIAgentRouteRefSerializer implements PrimitiveSerializer<AIAgentRouteRef> {
  @override
  final Iterable<Type> types = const [AIAgentRouteRef, _$AIAgentRouteRef];

  @override
  final String wireName = r'AIAgentRouteRef';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AIAgentRouteRef object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'agentKey';
    yield serializers.serialize(
      object.agentKey,
      specifiedType: const FullType(String),
    );
    if (object.model != null) {
      yield r'model';
      yield serializers.serialize(
        object.model,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.temperature != null) {
      yield r'temperature';
      yield serializers.serialize(
        object.temperature,
        specifiedType: const FullType.nullable(double),
      );
    }
    if (object.maxTokens != null) {
      yield r'maxTokens';
      yield serializers.serialize(
        object.maxTokens,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AIAgentRouteRef object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AIAgentRouteRefBuilder result,
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
        case r'model':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.model = valueDes;
          break;
        case r'temperature':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(double),
          ) as double?;
          if (valueDes == null) continue;
          result.temperature = valueDes;
          break;
        case r'maxTokens':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.maxTokens = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AIAgentRouteRef deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AIAgentRouteRefBuilder();
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

