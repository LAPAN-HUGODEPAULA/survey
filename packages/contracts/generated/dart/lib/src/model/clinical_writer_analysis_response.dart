//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/clinical_writer_alert.dart';
import 'package:survey_backend_api/src/model/clinical_writer_hypothesis.dart';
import 'package:built_collection/built_collection.dart';
import 'package:survey_backend_api/src/model/clinical_writer_suggestion.dart';
import 'package:survey_backend_api/src/model/clinical_writer_entity.dart';
import 'package:survey_backend_api/src/model/clinical_writer_knowledge_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'clinical_writer_analysis_response.g.dart';

/// ClinicalWriterAnalysisResponse
///
/// Properties:
/// * [suggestions] 
/// * [entities] 
/// * [alerts] 
/// * [hypotheses] 
/// * [knowledge] 
/// * [phase] 
@BuiltValue()
abstract class ClinicalWriterAnalysisResponse implements Built<ClinicalWriterAnalysisResponse, ClinicalWriterAnalysisResponseBuilder> {
  @BuiltValueField(wireName: r'suggestions')
  BuiltList<ClinicalWriterSuggestion>? get suggestions;

  @BuiltValueField(wireName: r'entities')
  BuiltList<ClinicalWriterEntity>? get entities;

  @BuiltValueField(wireName: r'alerts')
  BuiltList<ClinicalWriterAlert>? get alerts;

  @BuiltValueField(wireName: r'hypotheses')
  BuiltList<ClinicalWriterHypothesis>? get hypotheses;

  @BuiltValueField(wireName: r'knowledge')
  BuiltList<ClinicalWriterKnowledgeItem>? get knowledge;

  @BuiltValueField(wireName: r'phase')
  String? get phase;

  ClinicalWriterAnalysisResponse._();

  factory ClinicalWriterAnalysisResponse([void updates(ClinicalWriterAnalysisResponseBuilder b)]) = _$ClinicalWriterAnalysisResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClinicalWriterAnalysisResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClinicalWriterAnalysisResponse> get serializer => _$ClinicalWriterAnalysisResponseSerializer();
}

class _$ClinicalWriterAnalysisResponseSerializer implements PrimitiveSerializer<ClinicalWriterAnalysisResponse> {
  @override
  final Iterable<Type> types = const [ClinicalWriterAnalysisResponse, _$ClinicalWriterAnalysisResponse];

  @override
  final String wireName = r'ClinicalWriterAnalysisResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClinicalWriterAnalysisResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.suggestions != null) {
      yield r'suggestions';
      yield serializers.serialize(
        object.suggestions,
        specifiedType: const FullType(BuiltList, [FullType(ClinicalWriterSuggestion)]),
      );
    }
    if (object.entities != null) {
      yield r'entities';
      yield serializers.serialize(
        object.entities,
        specifiedType: const FullType(BuiltList, [FullType(ClinicalWriterEntity)]),
      );
    }
    if (object.alerts != null) {
      yield r'alerts';
      yield serializers.serialize(
        object.alerts,
        specifiedType: const FullType(BuiltList, [FullType(ClinicalWriterAlert)]),
      );
    }
    if (object.hypotheses != null) {
      yield r'hypotheses';
      yield serializers.serialize(
        object.hypotheses,
        specifiedType: const FullType(BuiltList, [FullType(ClinicalWriterHypothesis)]),
      );
    }
    if (object.knowledge != null) {
      yield r'knowledge';
      yield serializers.serialize(
        object.knowledge,
        specifiedType: const FullType(BuiltList, [FullType(ClinicalWriterKnowledgeItem)]),
      );
    }
    if (object.phase != null) {
      yield r'phase';
      yield serializers.serialize(
        object.phase,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ClinicalWriterAnalysisResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClinicalWriterAnalysisResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'suggestions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ClinicalWriterSuggestion)]),
          ) as BuiltList<ClinicalWriterSuggestion>;
          result.suggestions.replace(valueDes);
          break;
        case r'entities':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ClinicalWriterEntity)]),
          ) as BuiltList<ClinicalWriterEntity>;
          result.entities.replace(valueDes);
          break;
        case r'alerts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ClinicalWriterAlert)]),
          ) as BuiltList<ClinicalWriterAlert>;
          result.alerts.replace(valueDes);
          break;
        case r'hypotheses':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ClinicalWriterHypothesis)]),
          ) as BuiltList<ClinicalWriterHypothesis>;
          result.hypotheses.replace(valueDes);
          break;
        case r'knowledge':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ClinicalWriterKnowledgeItem)]),
          ) as BuiltList<ClinicalWriterKnowledgeItem>;
          result.knowledge.replace(valueDes);
          break;
        case r'phase':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phase = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClinicalWriterAnalysisResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClinicalWriterAnalysisResponseBuilder();
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

