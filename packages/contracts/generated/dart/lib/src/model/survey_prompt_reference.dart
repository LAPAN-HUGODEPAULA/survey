//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'survey_prompt_reference.g.dart';

/// SurveyPromptReference
///
/// Properties:
/// * [promptKey] 
/// * [name] 
@BuiltValue()
abstract class SurveyPromptReference implements Built<SurveyPromptReference, SurveyPromptReferenceBuilder> {
  @BuiltValueField(wireName: r'promptKey')
  String get promptKey;

  @BuiltValueField(wireName: r'name')
  String get name;

  SurveyPromptReference._();

  factory SurveyPromptReference([void updates(SurveyPromptReferenceBuilder b)]) = _$SurveyPromptReference;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SurveyPromptReferenceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SurveyPromptReference> get serializer => _$SurveyPromptReferenceSerializer();
}

class _$SurveyPromptReferenceSerializer implements PrimitiveSerializer<SurveyPromptReference> {
  @override
  final Iterable<Type> types = const [SurveyPromptReference, _$SurveyPromptReference];

  @override
  final String wireName = r'SurveyPromptReference';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SurveyPromptReference object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'promptKey';
    yield serializers.serialize(
      object.promptKey,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SurveyPromptReference object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SurveyPromptReferenceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'promptKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.promptKey = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SurveyPromptReference deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SurveyPromptReferenceBuilder();
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

