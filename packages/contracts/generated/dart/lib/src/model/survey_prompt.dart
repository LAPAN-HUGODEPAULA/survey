//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/survey_prompt_upsert.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'survey_prompt.g.dart';

/// SurveyPrompt
///
/// Properties:
/// * [promptKey] 
/// * [name] 
/// * [promptText] 
/// * [createdAt] 
/// * [modifiedAt] 
@BuiltValue()
abstract class SurveyPrompt implements SurveyPromptUpsert, Built<SurveyPrompt, SurveyPromptBuilder> {
  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'modifiedAt')
  DateTime get modifiedAt;

  SurveyPrompt._();

  factory SurveyPrompt([void updates(SurveyPromptBuilder b)]) = _$SurveyPrompt;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SurveyPromptBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SurveyPrompt> get serializer => _$SurveyPromptSerializer();
}

class _$SurveyPromptSerializer implements PrimitiveSerializer<SurveyPrompt> {
  @override
  final Iterable<Type> types = const [SurveyPrompt, _$SurveyPrompt];

  @override
  final String wireName = r'SurveyPrompt';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SurveyPrompt object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'promptKey';
    yield serializers.serialize(
      object.promptKey,
      specifiedType: const FullType(String),
    );
    yield r'promptText';
    yield serializers.serialize(
      object.promptText,
      specifiedType: const FullType(String),
    );
    yield r'modifiedAt';
    yield serializers.serialize(
      object.modifiedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SurveyPrompt object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SurveyPromptBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'promptKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.promptKey = valueDes;
          break;
        case r'promptText':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.promptText = valueDes;
          break;
        case r'modifiedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.modifiedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SurveyPrompt deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SurveyPromptBuilder();
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

