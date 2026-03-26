//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'survey_prompt_upsert.g.dart';

/// SurveyPromptUpsert
///
/// Properties:
/// * [promptKey] 
/// * [name] 
/// * [promptText] 
@BuiltValue(instantiable: false)
abstract class SurveyPromptUpsert  {
  @BuiltValueField(wireName: r'promptKey')
  String get promptKey;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'promptText')
  String get promptText;

  @BuiltValueSerializer(custom: true)
  static Serializer<SurveyPromptUpsert> get serializer => _$SurveyPromptUpsertSerializer();
}

class _$SurveyPromptUpsertSerializer implements PrimitiveSerializer<SurveyPromptUpsert> {
  @override
  final Iterable<Type> types = const [SurveyPromptUpsert];

  @override
  final String wireName = r'SurveyPromptUpsert';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SurveyPromptUpsert object, {
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
    yield r'promptText';
    yield serializers.serialize(
      object.promptText,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SurveyPromptUpsert object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  SurveyPromptUpsert deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($SurveyPromptUpsert)) as $SurveyPromptUpsert;
  }
}

/// a concrete implementation of [SurveyPromptUpsert], since [SurveyPromptUpsert] is not instantiable
@BuiltValue(instantiable: true)
abstract class $SurveyPromptUpsert implements SurveyPromptUpsert, Built<$SurveyPromptUpsert, $SurveyPromptUpsertBuilder> {
  $SurveyPromptUpsert._();

  factory $SurveyPromptUpsert([void Function($SurveyPromptUpsertBuilder)? updates]) = _$$SurveyPromptUpsert;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($SurveyPromptUpsertBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$SurveyPromptUpsert> get serializer => _$$SurveyPromptUpsertSerializer();
}

class _$$SurveyPromptUpsertSerializer implements PrimitiveSerializer<$SurveyPromptUpsert> {
  @override
  final Iterable<Type> types = const [$SurveyPromptUpsert, _$$SurveyPromptUpsert];

  @override
  final String wireName = r'$SurveyPromptUpsert';

  @override
  Object serialize(
    Serializers serializers,
    $SurveyPromptUpsert object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(SurveyPromptUpsert))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SurveyPromptUpsertBuilder result,
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
        case r'promptText':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.promptText = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  $SurveyPromptUpsert deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $SurveyPromptUpsertBuilder();
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

