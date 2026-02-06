//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_session_update.g.dart';

/// ChatSessionUpdate
///
/// Properties:
/// * [status] 
/// * [phase] 
/// * [metadata] 
@BuiltValue()
abstract class ChatSessionUpdate implements Built<ChatSessionUpdate, ChatSessionUpdateBuilder> {
  @BuiltValueField(wireName: r'status')
  String? get status;

  @BuiltValueField(wireName: r'phase')
  String? get phase;

  @BuiltValueField(wireName: r'metadata')
  JsonObject? get metadata;

  ChatSessionUpdate._();

  factory ChatSessionUpdate([void updates(ChatSessionUpdateBuilder b)]) = _$ChatSessionUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatSessionUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatSessionUpdate> get serializer => _$ChatSessionUpdateSerializer();
}

class _$ChatSessionUpdateSerializer implements PrimitiveSerializer<ChatSessionUpdate> {
  @override
  final Iterable<Type> types = const [ChatSessionUpdate, _$ChatSessionUpdate];

  @override
  final String wireName = r'ChatSessionUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatSessionUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(String),
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
    ChatSessionUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatSessionUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
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
  ChatSessionUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatSessionUpdateBuilder();
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

