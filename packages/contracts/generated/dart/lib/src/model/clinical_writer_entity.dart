//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'clinical_writer_entity.g.dart';

/// ClinicalWriterEntity
///
/// Properties:
/// * [type] 
/// * [value] 
/// * [confidence] 
@BuiltValue()
abstract class ClinicalWriterEntity implements Built<ClinicalWriterEntity, ClinicalWriterEntityBuilder> {
  @BuiltValueField(wireName: r'type')
  String? get type;

  @BuiltValueField(wireName: r'value')
  String? get value;

  @BuiltValueField(wireName: r'confidence')
  num? get confidence;

  ClinicalWriterEntity._();

  factory ClinicalWriterEntity([void updates(ClinicalWriterEntityBuilder b)]) = _$ClinicalWriterEntity;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClinicalWriterEntityBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClinicalWriterEntity> get serializer => _$ClinicalWriterEntitySerializer();
}

class _$ClinicalWriterEntitySerializer implements PrimitiveSerializer<ClinicalWriterEntity> {
  @override
  final Iterable<Type> types = const [ClinicalWriterEntity, _$ClinicalWriterEntity];

  @override
  final String wireName = r'ClinicalWriterEntity';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClinicalWriterEntity object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(String),
      );
    }
    if (object.value != null) {
      yield r'value';
      yield serializers.serialize(
        object.value,
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ClinicalWriterEntity object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClinicalWriterEntityBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        case r'value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.value = valueDes;
          break;
        case r'confidence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.confidence = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClinicalWriterEntity deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClinicalWriterEntityBuilder();
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

