//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/clinical_writer_analysis_message.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'clinical_writer_analysis_request.g.dart';

/// ClinicalWriterAnalysisRequest
///
/// Properties:
/// * [sessionId] 
/// * [phase] 
/// * [messages] 
@BuiltValue()
abstract class ClinicalWriterAnalysisRequest implements Built<ClinicalWriterAnalysisRequest, ClinicalWriterAnalysisRequestBuilder> {
  @BuiltValueField(wireName: r'sessionId')
  String? get sessionId;

  @BuiltValueField(wireName: r'phase')
  String? get phase;

  @BuiltValueField(wireName: r'messages')
  BuiltList<ClinicalWriterAnalysisMessage> get messages;

  ClinicalWriterAnalysisRequest._();

  factory ClinicalWriterAnalysisRequest([void updates(ClinicalWriterAnalysisRequestBuilder b)]) = _$ClinicalWriterAnalysisRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClinicalWriterAnalysisRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClinicalWriterAnalysisRequest> get serializer => _$ClinicalWriterAnalysisRequestSerializer();
}

class _$ClinicalWriterAnalysisRequestSerializer implements PrimitiveSerializer<ClinicalWriterAnalysisRequest> {
  @override
  final Iterable<Type> types = const [ClinicalWriterAnalysisRequest, _$ClinicalWriterAnalysisRequest];

  @override
  final String wireName = r'ClinicalWriterAnalysisRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClinicalWriterAnalysisRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.sessionId != null) {
      yield r'sessionId';
      yield serializers.serialize(
        object.sessionId,
        specifiedType: const FullType(String),
      );
    }
    if (object.phase != null) {
      yield r'phase';
      yield serializers.serialize(
        object.phase,
        specifiedType: const FullType(String),
      );
    }
    yield r'messages';
    yield serializers.serialize(
      object.messages,
      specifiedType: const FullType(BuiltList, [FullType(ClinicalWriterAnalysisMessage)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ClinicalWriterAnalysisRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClinicalWriterAnalysisRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sessionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sessionId = valueDes;
          break;
        case r'phase':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phase = valueDes;
          break;
        case r'messages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ClinicalWriterAnalysisMessage)]),
          ) as BuiltList<ClinicalWriterAnalysisMessage>;
          result.messages.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClinicalWriterAnalysisRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClinicalWriterAnalysisRequestBuilder();
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

