//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'clinical_writer_analysis_message.g.dart';

/// ClinicalWriterAnalysisMessage
///
/// Properties:
/// * [role] 
/// * [content] 
/// * [messageType] 
@BuiltValue()
abstract class ClinicalWriterAnalysisMessage implements Built<ClinicalWriterAnalysisMessage, ClinicalWriterAnalysisMessageBuilder> {
  @BuiltValueField(wireName: r'role')
  String get role;

  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'messageType')
  String get messageType;

  ClinicalWriterAnalysisMessage._();

  factory ClinicalWriterAnalysisMessage([void updates(ClinicalWriterAnalysisMessageBuilder b)]) = _$ClinicalWriterAnalysisMessage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClinicalWriterAnalysisMessageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClinicalWriterAnalysisMessage> get serializer => _$ClinicalWriterAnalysisMessageSerializer();
}

class _$ClinicalWriterAnalysisMessageSerializer implements PrimitiveSerializer<ClinicalWriterAnalysisMessage> {
  @override
  final Iterable<Type> types = const [ClinicalWriterAnalysisMessage, _$ClinicalWriterAnalysisMessage];

  @override
  final String wireName = r'ClinicalWriterAnalysisMessage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClinicalWriterAnalysisMessage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(String),
    );
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'messageType';
    yield serializers.serialize(
      object.messageType,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ClinicalWriterAnalysisMessage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClinicalWriterAnalysisMessageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.role = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'messageType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.messageType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClinicalWriterAnalysisMessage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClinicalWriterAnalysisMessageBuilder();
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

