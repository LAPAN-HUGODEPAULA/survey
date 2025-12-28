//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/patient.dart';
import 'package:survey_backend_api/src/model/answer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'survey_response.g.dart';

/// SurveyResponse
///
/// Properties:
/// * [id] 
/// * [id] 
/// * [surveyId] 
/// * [patient] 
/// * [answers] 
/// * [notes] 
@BuiltValue(instantiable: false)
abstract class SurveyResponse  {
  @BuiltValueField(wireName: r'_id')
  String? get id;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'surveyId')
  String get surveyId;

  @BuiltValueField(wireName: r'patient')
  Patient get patient;

  @BuiltValueField(wireName: r'answers')
  BuiltList<Answer> get answers;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueSerializer(custom: true)
  static Serializer<SurveyResponse> get serializer => _$SurveyResponseSerializer();
}

class _$SurveyResponseSerializer implements PrimitiveSerializer<SurveyResponse> {
  @override
  final Iterable<Type> types = const [SurveyResponse];

  @override
  final String wireName = r'SurveyResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SurveyResponse object, {
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
    yield r'surveyId';
    yield serializers.serialize(
      object.surveyId,
      specifiedType: const FullType(String),
    );
    yield r'patient';
    yield serializers.serialize(
      object.patient,
      specifiedType: const FullType(Patient),
    );
    yield r'answers';
    yield serializers.serialize(
      object.answers,
      specifiedType: const FullType(BuiltList, [FullType(Answer)]),
    );
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SurveyResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  SurveyResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($SurveyResponse)) as $SurveyResponse;
  }
}

/// a concrete implementation of [SurveyResponse], since [SurveyResponse] is not instantiable
@BuiltValue(instantiable: true)
abstract class $SurveyResponse implements SurveyResponse, Built<$SurveyResponse, $SurveyResponseBuilder> {
  $SurveyResponse._();

  factory $SurveyResponse([void Function($SurveyResponseBuilder)? updates]) = _$$SurveyResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($SurveyResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$SurveyResponse> get serializer => _$$SurveyResponseSerializer();
}

class _$$SurveyResponseSerializer implements PrimitiveSerializer<$SurveyResponse> {
  @override
  final Iterable<Type> types = const [$SurveyResponse, _$$SurveyResponse];

  @override
  final String wireName = r'$SurveyResponse';

  @override
  Object serialize(
    Serializers serializers,
    $SurveyResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(SurveyResponse))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SurveyResponseBuilder result,
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
        case r'surveyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.surveyId = valueDes;
          break;
        case r'patient':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Patient),
          ) as Patient;
          result.patient.replace(valueDes);
          break;
        case r'answers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Answer)]),
          ) as BuiltList<Answer>;
          result.answers.replace(valueDes);
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.notes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  $SurveyResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $SurveyResponseBuilder();
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

