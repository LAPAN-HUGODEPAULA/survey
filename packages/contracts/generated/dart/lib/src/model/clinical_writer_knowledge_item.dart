//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'clinical_writer_knowledge_item.g.dart';

/// ClinicalWriterKnowledgeItem
///
/// Properties:
/// * [id] 
/// * [label] 
/// * [source_] 
/// * [reference] 
@BuiltValue()
abstract class ClinicalWriterKnowledgeItem implements Built<ClinicalWriterKnowledgeItem, ClinicalWriterKnowledgeItemBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'label')
  String? get label;

  @BuiltValueField(wireName: r'source')
  String? get source_;

  @BuiltValueField(wireName: r'reference')
  String? get reference;

  ClinicalWriterKnowledgeItem._();

  factory ClinicalWriterKnowledgeItem([void updates(ClinicalWriterKnowledgeItemBuilder b)]) = _$ClinicalWriterKnowledgeItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClinicalWriterKnowledgeItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClinicalWriterKnowledgeItem> get serializer => _$ClinicalWriterKnowledgeItemSerializer();
}

class _$ClinicalWriterKnowledgeItemSerializer implements PrimitiveSerializer<ClinicalWriterKnowledgeItem> {
  @override
  final Iterable<Type> types = const [ClinicalWriterKnowledgeItem, _$ClinicalWriterKnowledgeItem];

  @override
  final String wireName = r'ClinicalWriterKnowledgeItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClinicalWriterKnowledgeItem object, {
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
    if (object.source_ != null) {
      yield r'source';
      yield serializers.serialize(
        object.source_,
        specifiedType: const FullType(String),
      );
    }
    if (object.reference != null) {
      yield r'reference';
      yield serializers.serialize(
        object.reference,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ClinicalWriterKnowledgeItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClinicalWriterKnowledgeItemBuilder result,
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
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.source_ = valueDes;
          break;
        case r'reference':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reference = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClinicalWriterKnowledgeItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClinicalWriterKnowledgeItemBuilder();
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

