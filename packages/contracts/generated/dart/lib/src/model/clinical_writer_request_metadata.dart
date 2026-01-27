//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'clinical_writer_request_metadata.g.dart';

/// ClinicalWriterRequestMetadata
///
/// Properties:
/// * [sourceApp] 
/// * [requestId] 
/// * [patientRef] 
@BuiltValue()
abstract class ClinicalWriterRequestMetadata implements Built<ClinicalWriterRequestMetadata, ClinicalWriterRequestMetadataBuilder> {
  @BuiltValueField(wireName: r'source_app')
  String? get sourceApp;

  @BuiltValueField(wireName: r'request_id')
  String? get requestId;

  @BuiltValueField(wireName: r'patient_ref')
  String? get patientRef;

  ClinicalWriterRequestMetadata._();

  factory ClinicalWriterRequestMetadata([void updates(ClinicalWriterRequestMetadataBuilder b)]) = _$ClinicalWriterRequestMetadata;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClinicalWriterRequestMetadataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClinicalWriterRequestMetadata> get serializer => _$ClinicalWriterRequestMetadataSerializer();
}

class _$ClinicalWriterRequestMetadataSerializer implements PrimitiveSerializer<ClinicalWriterRequestMetadata> {
  @override
  final Iterable<Type> types = const [ClinicalWriterRequestMetadata, _$ClinicalWriterRequestMetadata];

  @override
  final String wireName = r'ClinicalWriterRequestMetadata';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClinicalWriterRequestMetadata object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.sourceApp != null) {
      yield r'source_app';
      yield serializers.serialize(
        object.sourceApp,
        specifiedType: const FullType(String),
      );
    }
    if (object.requestId != null) {
      yield r'request_id';
      yield serializers.serialize(
        object.requestId,
        specifiedType: const FullType(String),
      );
    }
    if (object.patientRef != null) {
      yield r'patient_ref';
      yield serializers.serialize(
        object.patientRef,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ClinicalWriterRequestMetadata object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClinicalWriterRequestMetadataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'source_app':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceApp = valueDes;
          break;
        case r'request_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestId = valueDes;
          break;
        case r'patient_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.patientRef = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClinicalWriterRequestMetadata deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClinicalWriterRequestMetadataBuilder();
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

