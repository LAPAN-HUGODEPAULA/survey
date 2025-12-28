//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/question.dart';
import 'package:built_collection/built_collection.dart';
import 'package:survey_backend_api/src/model/instructions.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'survey.g.dart';

/// Survey
///
/// Properties:
/// * [id] 
/// * [id] 
/// * [surveyDisplayName] 
/// * [surveyName] 
/// * [surveyDescription] 
/// * [creatorName] 
/// * [creatorContact] 
/// * [createdAt] 
/// * [modifiedAt] 
/// * [instructions] 
/// * [questions] 
/// * [finalNotes] 
@BuiltValue()
abstract class Survey implements Built<Survey, SurveyBuilder> {
  @BuiltValueField(wireName: r'_id')
  String? get id;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'surveyDisplayName')
  String get surveyDisplayName;

  @BuiltValueField(wireName: r'surveyName')
  String get surveyName;

  @BuiltValueField(wireName: r'surveyDescription')
  String get surveyDescription;

  @BuiltValueField(wireName: r'creatorName')
  String get creatorName;

  @BuiltValueField(wireName: r'creatorContact')
  String get creatorContact;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'modifiedAt')
  DateTime get modifiedAt;

  @BuiltValueField(wireName: r'instructions')
  Instructions get instructions;

  @BuiltValueField(wireName: r'questions')
  BuiltList<Question> get questions;

  @BuiltValueField(wireName: r'finalNotes')
  String get finalNotes;

  Survey._();

  factory Survey([void updates(SurveyBuilder b)]) = _$Survey;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SurveyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Survey> get serializer => _$SurveySerializer();
}

class _$SurveySerializer implements PrimitiveSerializer<Survey> {
  @override
  final Iterable<Type> types = const [Survey, _$Survey];

  @override
  final String wireName = r'Survey';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Survey object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'_id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    yield r'surveyDisplayName';
    yield serializers.serialize(
      object.surveyDisplayName,
      specifiedType: const FullType(String),
    );
    yield r'surveyName';
    yield serializers.serialize(
      object.surveyName,
      specifiedType: const FullType(String),
    );
    yield r'surveyDescription';
    yield serializers.serialize(
      object.surveyDescription,
      specifiedType: const FullType(String),
    );
    yield r'creatorName';
    yield serializers.serialize(
      object.creatorName,
      specifiedType: const FullType(String),
    );
    yield r'creatorContact';
    yield serializers.serialize(
      object.creatorContact,
      specifiedType: const FullType(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'modifiedAt';
    yield serializers.serialize(
      object.modifiedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'instructions';
    yield serializers.serialize(
      object.instructions,
      specifiedType: const FullType(Instructions),
    );
    yield r'questions';
    yield serializers.serialize(
      object.questions,
      specifiedType: const FullType(BuiltList, [FullType(Question)]),
    );
    yield r'finalNotes';
    yield serializers.serialize(
      object.finalNotes,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Survey object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SurveyBuilder result,
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
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'surveyDisplayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.surveyDisplayName = valueDes;
          break;
        case r'surveyName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.surveyName = valueDes;
          break;
        case r'surveyDescription':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.surveyDescription = valueDes;
          break;
        case r'creatorName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.creatorName = valueDes;
          break;
        case r'creatorContact':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.creatorContact = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'modifiedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.modifiedAt = valueDes;
          break;
        case r'instructions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Instructions),
          ) as Instructions;
          result.instructions.replace(valueDes);
          break;
        case r'questions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Question)]),
          ) as BuiltList<Question>;
          result.questions.replace(valueDes);
          break;
        case r'finalNotes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.finalNotes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Survey deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SurveyBuilder();
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

