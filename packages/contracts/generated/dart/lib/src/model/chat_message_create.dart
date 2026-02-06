//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_message_create.g.dart';

/// ChatMessageCreate
///
/// Properties:
/// * [role] 
/// * [messageType] 
/// * [content] 
/// * [metadata] 
@BuiltValue()
abstract class ChatMessageCreate implements Built<ChatMessageCreate, ChatMessageCreateBuilder> {
  @BuiltValueField(wireName: r'role')
  String get role;

  @BuiltValueField(wireName: r'messageType')
  String get messageType;

  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'metadata')
  JsonObject? get metadata;

  ChatMessageCreate._();

  factory ChatMessageCreate([void updates(ChatMessageCreateBuilder b)]) = _$ChatMessageCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatMessageCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatMessageCreate> get serializer => _$ChatMessageCreateSerializer();
}

class _$ChatMessageCreateSerializer implements PrimitiveSerializer<ChatMessageCreate> {
  @override
  final Iterable<Type> types = const [ChatMessageCreate, _$ChatMessageCreate];

  @override
  final String wireName = r'ChatMessageCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatMessageCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(String),
    );
    yield r'messageType';
    yield serializers.serialize(
      object.messageType,
      specifiedType: const FullType(String),
    );
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
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
    ChatMessageCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatMessageCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.role = valueDes;
          break;
        case r'messageType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.messageType = valueDes;
          break;
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
  ChatMessageCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatMessageCreateBuilder();
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

