//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'clinical_writer_task_error.g.dart';

/// ClinicalWriterTaskError
///
/// Properties:
/// * [retryable] 
/// * [userMessage] 
/// * [detail] 
@BuiltValue()
abstract class ClinicalWriterTaskError implements Built<ClinicalWriterTaskError, ClinicalWriterTaskErrorBuilder> {
  @BuiltValueField(wireName: r'retryable')
  bool get retryable;

  @BuiltValueField(wireName: r'userMessage')
  String get userMessage;

  @BuiltValueField(wireName: r'detail')
  String? get detail;

  ClinicalWriterTaskError._();

  factory ClinicalWriterTaskError([void updates(ClinicalWriterTaskErrorBuilder b)]) = _$ClinicalWriterTaskError;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClinicalWriterTaskErrorBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClinicalWriterTaskError> get serializer => _$ClinicalWriterTaskErrorSerializer();
}

class _$ClinicalWriterTaskErrorSerializer implements PrimitiveSerializer<ClinicalWriterTaskError> {
  @override
  final Iterable<Type> types = const [ClinicalWriterTaskError, _$ClinicalWriterTaskError];

  @override
  final String wireName = r'ClinicalWriterTaskError';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClinicalWriterTaskError object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'retryable';
    yield serializers.serialize(
      object.retryable,
      specifiedType: const FullType(bool),
    );
    yield r'userMessage';
    yield serializers.serialize(
      object.userMessage,
      specifiedType: const FullType(String),
    );
    if (object.detail != null) {
      yield r'detail';
      yield serializers.serialize(
        object.detail,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ClinicalWriterTaskError object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClinicalWriterTaskErrorBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'retryable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.retryable = valueDes;
          break;
        case r'userMessage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userMessage = valueDes;
          break;
        case r'detail':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.detail = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClinicalWriterTaskError deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClinicalWriterTaskErrorBuilder();
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

