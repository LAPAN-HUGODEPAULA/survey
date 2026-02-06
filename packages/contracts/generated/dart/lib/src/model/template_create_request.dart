//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:survey_backend_api/src/model/template_document_type.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'template_create_request.g.dart';

/// TemplateCreateRequest
///
/// Properties:
/// * [name] 
/// * [documentType] 
/// * [body] 
/// * [placeholders] 
/// * [conditions] 
@BuiltValue()
abstract class TemplateCreateRequest implements Built<TemplateCreateRequest, TemplateCreateRequestBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'documentType')
  TemplateDocumentType get documentType;
  // enum documentTypeEnum {  consultation_record,  prescription,  referral,  certificate,  technical_report,  clinical_progress,  };

  @BuiltValueField(wireName: r'body')
  String get body;

  @BuiltValueField(wireName: r'placeholders')
  BuiltList<String>? get placeholders;

  @BuiltValueField(wireName: r'conditions')
  BuiltList<JsonObject>? get conditions;

  TemplateCreateRequest._();

  factory TemplateCreateRequest([void updates(TemplateCreateRequestBuilder b)]) = _$TemplateCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TemplateCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TemplateCreateRequest> get serializer => _$TemplateCreateRequestSerializer();
}

class _$TemplateCreateRequestSerializer implements PrimitiveSerializer<TemplateCreateRequest> {
  @override
  final Iterable<Type> types = const [TemplateCreateRequest, _$TemplateCreateRequest];

  @override
  final String wireName = r'TemplateCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TemplateCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'documentType';
    yield serializers.serialize(
      object.documentType,
      specifiedType: const FullType(TemplateDocumentType),
    );
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
    if (object.placeholders != null) {
      yield r'placeholders';
      yield serializers.serialize(
        object.placeholders,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.conditions != null) {
      yield r'conditions';
      yield serializers.serialize(
        object.conditions,
        specifiedType: const FullType(BuiltList, [FullType(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TemplateCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TemplateCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'documentType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TemplateDocumentType),
          ) as TemplateDocumentType;
          result.documentType = valueDes;
          break;
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.body = valueDes;
          break;
        case r'placeholders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.placeholders.replace(valueDes);
          break;
        case r'conditions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(JsonObject)]),
          ) as BuiltList<JsonObject>;
          result.conditions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TemplateCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TemplateCreateRequestBuilder();
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

