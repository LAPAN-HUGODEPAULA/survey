//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'agent_response.g.dart';

/// AgentResponse
///
/// Properties:
/// * [classification] 
/// * [medicalRecord] 
/// * [errorMessage] 
@BuiltValue()
abstract class AgentResponse implements Built<AgentResponse, AgentResponseBuilder> {
  @BuiltValueField(wireName: r'classification')
  String? get classification;

  @BuiltValueField(wireName: r'medicalRecord')
  String? get medicalRecord;

  @BuiltValueField(wireName: r'errorMessage')
  String? get errorMessage;

  AgentResponse._();

  factory AgentResponse([void updates(AgentResponseBuilder b)]) = _$AgentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AgentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AgentResponse> get serializer => _$AgentResponseSerializer();
}

class _$AgentResponseSerializer implements PrimitiveSerializer<AgentResponse> {
  @override
  final Iterable<Type> types = const [AgentResponse, _$AgentResponse];

  @override
  final String wireName = r'AgentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AgentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.classification != null) {
      yield r'classification';
      yield serializers.serialize(
        object.classification,
        specifiedType: const FullType(String),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    AgentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AgentResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'classification':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.classification = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AgentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AgentResponseBuilder();
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

