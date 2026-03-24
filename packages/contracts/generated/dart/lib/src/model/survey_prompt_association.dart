//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/survey_prompt_outcome_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'survey_prompt_association.g.dart';

/// SurveyPromptAssociation
///
/// Properties:
/// * [promptKey] 
/// * [name] 
/// * [outcomeType] 
@BuiltValue()
abstract class SurveyPromptAssociation implements Built<SurveyPromptAssociation, SurveyPromptAssociationBuilder> {
  @BuiltValueField(wireName: r'promptKey')
  String get promptKey;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'outcomeType')
  SurveyPromptOutcomeType get outcomeType;
  // enum outcomeTypeEnum {  patient_condition_overview,  clinical_diagnostic_report,  clinical_referral_letter,  parental_guidance,  educational_support_summary,  };

  SurveyPromptAssociation._();

  factory SurveyPromptAssociation([void updates(SurveyPromptAssociationBuilder b)]) = _$SurveyPromptAssociation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SurveyPromptAssociationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SurveyPromptAssociation> get serializer => _$SurveyPromptAssociationSerializer();
}

class _$SurveyPromptAssociationSerializer implements PrimitiveSerializer<SurveyPromptAssociation> {
  @override
  final Iterable<Type> types = const [SurveyPromptAssociation, _$SurveyPromptAssociation];

  @override
  final String wireName = r'SurveyPromptAssociation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SurveyPromptAssociation object, {
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
    yield r'outcomeType';
    yield serializers.serialize(
      object.outcomeType,
      specifiedType: const FullType(SurveyPromptOutcomeType),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SurveyPromptAssociation object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SurveyPromptAssociationBuilder result,
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
        case r'outcomeType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SurveyPromptOutcomeType),
          ) as SurveyPromptOutcomeType;
          result.outcomeType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SurveyPromptAssociation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SurveyPromptAssociationBuilder();
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

