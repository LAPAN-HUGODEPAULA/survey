//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'instructions.g.dart';

/// Instructions
///
/// Properties:
/// * [preamble] 
/// * [questionText] 
/// * [answers] 
@BuiltValue()
abstract class Instructions implements Built<Instructions, InstructionsBuilder> {
  @BuiltValueField(wireName: r'preamble')
  String get preamble;

  @BuiltValueField(wireName: r'questionText')
  String get questionText;

  @BuiltValueField(wireName: r'answers')
  BuiltList<String> get answers;

  Instructions._();

  factory Instructions([void updates(InstructionsBuilder b)]) = _$Instructions;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InstructionsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Instructions> get serializer => _$InstructionsSerializer();
}

class _$InstructionsSerializer implements PrimitiveSerializer<Instructions> {
  @override
  final Iterable<Type> types = const [Instructions, _$Instructions];

  @override
  final String wireName = r'Instructions';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Instructions object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'preamble';
    yield serializers.serialize(
      object.preamble,
      specifiedType: const FullType(String),
    );
    yield r'questionText';
    yield serializers.serialize(
      object.questionText,
      specifiedType: const FullType(String),
    );
    yield r'answers';
    yield serializers.serialize(
      object.answers,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Instructions object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InstructionsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'preamble':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.preamble = valueDes;
          break;
        case r'questionText':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.questionText = valueDes;
          break;
        case r'answers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.answers.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Instructions deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InstructionsBuilder();
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

