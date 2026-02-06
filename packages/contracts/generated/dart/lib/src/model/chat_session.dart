//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_session.g.dart';

/// ChatSession
///
/// Properties:
/// * [id] 
/// * [status] 
/// * [phase] 
/// * [patientId] 
/// * [createdAt] 
/// * [updatedAt] 
/// * [completedAt] 
/// * [metadata] 
@BuiltValue()
abstract class ChatSession implements Built<ChatSession, ChatSessionBuilder> {
  @BuiltValueField(wireName: r'_id')
  String? get id;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'phase')
  String get phase;

  @BuiltValueField(wireName: r'patientId')
  String? get patientId;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'completedAt')
  DateTime? get completedAt;

  @BuiltValueField(wireName: r'metadata')
  JsonObject? get metadata;

  ChatSession._();

  factory ChatSession([void updates(ChatSessionBuilder b)]) = _$ChatSession;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatSessionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatSession> get serializer => _$ChatSessionSerializer();
}

class _$ChatSessionSerializer implements PrimitiveSerializer<ChatSession> {
  @override
  final Iterable<Type> types = const [ChatSession, _$ChatSession];

  @override
  final String wireName = r'ChatSession';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatSession object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'_id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'phase';
    yield serializers.serialize(
      object.phase,
      specifiedType: const FullType(String),
    );
    if (object.patientId != null) {
      yield r'patientId';
      yield serializers.serialize(
        object.patientId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.completedAt != null) {
      yield r'completedAt';
      yield serializers.serialize(
        object.completedAt,
        specifiedType: const FullType.nullable(DateTime),
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
    ChatSession object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatSessionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
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
        case r'patientId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.patientId = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'completedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.completedAt = valueDes;
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
  ChatSession deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatSessionBuilder();
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

