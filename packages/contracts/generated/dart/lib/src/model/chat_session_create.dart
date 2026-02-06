//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_session_create.g.dart';

/// ChatSessionCreate
///
/// Properties:
/// * [patientId] 
/// * [phase] 
/// * [metadata] 
@BuiltValue()
abstract class ChatSessionCreate implements Built<ChatSessionCreate, ChatSessionCreateBuilder> {
  @BuiltValueField(wireName: r'patientId')
  String? get patientId;

  @BuiltValueField(wireName: r'phase')
  String? get phase;

  @BuiltValueField(wireName: r'metadata')
  JsonObject? get metadata;

  ChatSessionCreate._();

  factory ChatSessionCreate([void updates(ChatSessionCreateBuilder b)]) = _$ChatSessionCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatSessionCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatSessionCreate> get serializer => _$ChatSessionCreateSerializer();
}

class _$ChatSessionCreateSerializer implements PrimitiveSerializer<ChatSessionCreate> {
  @override
  final Iterable<Type> types = const [ChatSessionCreate, _$ChatSessionCreate];

  @override
  final String wireName = r'ChatSessionCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatSessionCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.patientId != null) {
      yield r'patientId';
      yield serializers.serialize(
        object.patientId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.phase != null) {
      yield r'phase';
      yield serializers.serialize(
        object.phase,
        specifiedType: const FullType(String),
      );
    }
    if (object.metadata != null) {
      yield r'metadata';
      yield serializers.serialize(
        object.metadata,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatSessionCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatSessionCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'patientId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.patientId = valueDes;
          break;
        case r'phase':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phase = valueDes;
          break;
        case r'metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.metadata = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatSessionCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatSessionCreateBuilder();
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

