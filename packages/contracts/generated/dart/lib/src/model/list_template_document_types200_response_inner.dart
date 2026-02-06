//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/template_document_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_template_document_types200_response_inner.g.dart';

/// ListTemplateDocumentTypes200ResponseInner
///
/// Properties:
/// * [id] 
/// * [label] 
@BuiltValue()
abstract class ListTemplateDocumentTypes200ResponseInner implements Built<ListTemplateDocumentTypes200ResponseInner, ListTemplateDocumentTypes200ResponseInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  TemplateDocumentType? get id;
  // enum idEnum {  consultation_record,  prescription,  referral,  certificate,  technical_report,  clinical_progress,  };

  @BuiltValueField(wireName: r'label')
  String? get label;

  ListTemplateDocumentTypes200ResponseInner._();

  factory ListTemplateDocumentTypes200ResponseInner([void updates(ListTemplateDocumentTypes200ResponseInnerBuilder b)]) = _$ListTemplateDocumentTypes200ResponseInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListTemplateDocumentTypes200ResponseInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListTemplateDocumentTypes200ResponseInner> get serializer => _$ListTemplateDocumentTypes200ResponseInnerSerializer();
}

class _$ListTemplateDocumentTypes200ResponseInnerSerializer implements PrimitiveSerializer<ListTemplateDocumentTypes200ResponseInner> {
  @override
  final Iterable<Type> types = const [ListTemplateDocumentTypes200ResponseInner, _$ListTemplateDocumentTypes200ResponseInner];

  @override
  final String wireName = r'ListTemplateDocumentTypes200ResponseInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListTemplateDocumentTypes200ResponseInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(TemplateDocumentType),
      );
    }
    if (object.label != null) {
      yield r'label';
      yield serializers.serialize(
        object.label,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ListTemplateDocumentTypes200ResponseInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListTemplateDocumentTypes200ResponseInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TemplateDocumentType),
          ) as TemplateDocumentType;
          result.id = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListTemplateDocumentTypes200ResponseInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListTemplateDocumentTypes200ResponseInnerBuilder();
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

