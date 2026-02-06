//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'clinical_writer_suggestion.g.dart';

/// ClinicalWriterSuggestion
///
/// Properties:
/// * [id] 
/// * [text] 
/// * [category] 
/// * [confidence] 
@BuiltValue()
abstract class ClinicalWriterSuggestion implements Built<ClinicalWriterSuggestion, ClinicalWriterSuggestionBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'text')
  String? get text;

  @BuiltValueField(wireName: r'category')
  String? get category;

  @BuiltValueField(wireName: r'confidence')
  num? get confidence;

  ClinicalWriterSuggestion._();

  factory ClinicalWriterSuggestion([void updates(ClinicalWriterSuggestionBuilder b)]) = _$ClinicalWriterSuggestion;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClinicalWriterSuggestionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClinicalWriterSuggestion> get serializer => _$ClinicalWriterSuggestionSerializer();
}

class _$ClinicalWriterSuggestionSerializer implements PrimitiveSerializer<ClinicalWriterSuggestion> {
  @override
  final Iterable<Type> types = const [ClinicalWriterSuggestion, _$ClinicalWriterSuggestion];

  @override
  final String wireName = r'ClinicalWriterSuggestion';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClinicalWriterSuggestion object, {
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
    if (object.category != null) {
      yield r'category';
      yield serializers.serialize(
        object.category,
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
    ClinicalWriterSuggestion object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClinicalWriterSuggestionBuilder result,
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
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.category = valueDes;
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
  ClinicalWriterSuggestion deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClinicalWriterSuggestionBuilder();
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

