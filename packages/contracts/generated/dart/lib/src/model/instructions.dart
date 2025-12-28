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
/// * [steps] 
@BuiltValue()
abstract class Instructions implements Built<Instructions, InstructionsBuilder> {
  @BuiltValueField(wireName: r'preamble')
  String? get preamble;

  @BuiltValueField(wireName: r'steps')
  BuiltList<String>? get steps;

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
    if (object.preamble != null) {
      yield r'preamble';
      yield serializers.serialize(
        object.preamble,
        specifiedType: const FullType(String),
      );
    }
    if (object.steps != null) {
      yield r'steps';
      yield serializers.serialize(
        object.steps,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
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
        case r'steps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.steps.replace(valueDes);
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

