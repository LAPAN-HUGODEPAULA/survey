//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_message_update.g.dart';

/// ChatMessageUpdate
///
/// Properties:
/// * [content] 
/// * [metadata] 
@BuiltValue()
abstract class ChatMessageUpdate implements Built<ChatMessageUpdate, ChatMessageUpdateBuilder> {
  @BuiltValueField(wireName: r'content')
  String? get content;

  @BuiltValueField(wireName: r'metadata')
  JsonObject? get metadata;

  ChatMessageUpdate._();

  factory ChatMessageUpdate([void updates(ChatMessageUpdateBuilder b)]) = _$ChatMessageUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatMessageUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatMessageUpdate> get serializer => _$ChatMessageUpdateSerializer();
}

class _$ChatMessageUpdateSerializer implements PrimitiveSerializer<ChatMessageUpdate> {
  @override
  final Iterable<Type> types = const [ChatMessageUpdate, _$ChatMessageUpdate];

  @override
  final String wireName = r'ChatMessageUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatMessageUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
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
    ChatMessageUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatMessageUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
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
  ChatMessageUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatMessageUpdateBuilder();
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

