//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'clinical_writer_alert.g.dart';

/// ClinicalWriterAlert
///
/// Properties:
/// * [id] 
/// * [text] 
/// * [severity] 
/// * [evidence] 
@BuiltValue()
abstract class ClinicalWriterAlert implements Built<ClinicalWriterAlert, ClinicalWriterAlertBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'text')
  String? get text;

  @BuiltValueField(wireName: r'severity')
  String? get severity;

  @BuiltValueField(wireName: r'evidence')
  String? get evidence;

  ClinicalWriterAlert._();

  factory ClinicalWriterAlert([void updates(ClinicalWriterAlertBuilder b)]) = _$ClinicalWriterAlert;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClinicalWriterAlertBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClinicalWriterAlert> get serializer => _$ClinicalWriterAlertSerializer();
}

class _$ClinicalWriterAlertSerializer implements PrimitiveSerializer<ClinicalWriterAlert> {
  @override
  final Iterable<Type> types = const [ClinicalWriterAlert, _$ClinicalWriterAlert];

  @override
  final String wireName = r'ClinicalWriterAlert';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClinicalWriterAlert object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.text != null) {
      yield r'text';
      yield serializers.serialize(
        object.text,
        specifiedType: const FullType(String),
      );
    }
    if (object.severity != null) {
      yield r'severity';
      yield serializers.serialize(
        object.severity,
        specifiedType: const FullType(String),
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
    ClinicalWriterAlert object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClinicalWriterAlertBuilder result,
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
        case r'text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.text = valueDes;
          break;
        case r'severity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.severity = valueDes;
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
  ClinicalWriterAlert deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClinicalWriterAlertBuilder();
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

