//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'clinical_writer_hypothesis.g.dart';

/// ClinicalWriterHypothesis
///
/// Properties:
/// * [id] 
/// * [label] 
/// * [confidence] 
/// * [evidence] 
@BuiltValue()
abstract class ClinicalWriterHypothesis implements Built<ClinicalWriterHypothesis, ClinicalWriterHypothesisBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'label')
  String? get label;

  @BuiltValueField(wireName: r'confidence')
  num? get confidence;

  @BuiltValueField(wireName: r'evidence')
  String? get evidence;

  ClinicalWriterHypothesis._();

  factory ClinicalWriterHypothesis([void updates(ClinicalWriterHypothesisBuilder b)]) = _$ClinicalWriterHypothesis;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClinicalWriterHypothesisBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClinicalWriterHypothesis> get serializer => _$ClinicalWriterHypothesisSerializer();
}

class _$ClinicalWriterHypothesisSerializer implements PrimitiveSerializer<ClinicalWriterHypothesis> {
  @override
  final Iterable<Type> types = const [ClinicalWriterHypothesis, _$ClinicalWriterHypothesis];

  @override
  final String wireName = r'ClinicalWriterHypothesis';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClinicalWriterHypothesis object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.label != null) {
      yield r'label';
      yield serializers.serialize(
        object.label,
        specifiedType: const FullType(String),
      );
    }
    if (object.confidence != null) {
      yield r'confidence';
      yield serializers.serialize(
        object.confidence,
        specifiedType: const FullType(num),
      );
    }
    if (object.evidence != null) {
      yield r'evidence';
      yield serializers.serialize(
        object.evidence,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ClinicalWriterHypothesis object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClinicalWriterHypothesisBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        case r'confidence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.confidence = valueDes;
          break;
        case r'evidence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.evidence = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClinicalWriterHypothesis deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClinicalWriterHypothesisBuilder();
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

