//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'answer.g.dart';

/// Answer
///
/// Properties:
/// * [questionId] 
/// * [response] 
@BuiltValue()
abstract class Answer implements Built<Answer, AnswerBuilder> {
  @BuiltValueField(wireName: r'questionId')
  int? get questionId;

  @BuiltValueField(wireName: r'response')
  String? get response;

  Answer._();

  factory Answer([void updates(AnswerBuilder b)]) = _$Answer;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnswerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Answer> get serializer => _$AnswerSerializer();
}

class _$AnswerSerializer implements PrimitiveSerializer<Answer> {
  @override
  final Iterable<Type> types = const [Answer, _$Answer];

  @override
  final String wireName = r'Answer';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Answer object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.questionId != null) {
      yield r'questionId';
      yield serializers.serialize(
        object.questionId,
        specifiedType: const FullType(int),
      );
    }
    if (object.response != null) {
      yield r'response';
      yield serializers.serialize(
        object.response,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Answer object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AnswerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'questionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.questionId = valueDes;
          break;
        case r'response':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.response = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Answer deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnswerBuilder();
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

