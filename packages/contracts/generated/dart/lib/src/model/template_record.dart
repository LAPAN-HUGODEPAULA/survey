//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:survey_backend_api/src/model/template_document_type.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'template_record.g.dart';

/// TemplateRecord
///
/// Properties:
/// * [id] 
/// * [templateGroupId] 
/// * [name] 
/// * [documentType] 
/// * [version] 
/// * [status] 
/// * [body] 
/// * [placeholders] 
/// * [conditions] 
/// * [createdAt] 
/// * [updatedAt] 
/// * [approvedAt] 
/// * [createdBy] 
/// * [updatedBy] 
/// * [approvedBy] 
@BuiltValue()
abstract class TemplateRecord implements Built<TemplateRecord, TemplateRecordBuilder> {
  @BuiltValueField(wireName: r'_id')
  String? get id;

  @BuiltValueField(wireName: r'templateGroupId')
  String? get templateGroupId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'documentType')
  TemplateDocumentType get documentType;
  // enum documentTypeEnum {  consultation_record,  prescription,  referral,  certificate,  technical_report,  clinical_progress,  };

  @BuiltValueField(wireName: r'version')
  String get version;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'body')
  String get body;

  @BuiltValueField(wireName: r'placeholders')
  BuiltList<String> get placeholders;

  @BuiltValueField(wireName: r'conditions')
  BuiltList<JsonObject>? get conditions;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'approvedAt')
  DateTime? get approvedAt;

  @BuiltValueField(wireName: r'createdBy')
  String? get createdBy;

  @BuiltValueField(wireName: r'updatedBy')
  String? get updatedBy;

  @BuiltValueField(wireName: r'approvedBy')
  String? get approvedBy;

  TemplateRecord._();

  factory TemplateRecord([void updates(TemplateRecordBuilder b)]) = _$TemplateRecord;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TemplateRecordBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TemplateRecord> get serializer => _$TemplateRecordSerializer();
}

class _$TemplateRecordSerializer implements PrimitiveSerializer<TemplateRecord> {
  @override
  final Iterable<Type> types = const [TemplateRecord, _$TemplateRecord];

  @override
  final String wireName = r'TemplateRecord';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TemplateRecord object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'_id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.templateGroupId != null) {
      yield r'templateGroupId';
      yield serializers.serialize(
        object.templateGroupId,
        specifiedType: const FullType(String),
      );
    }
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
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
    yield r'placeholders';
    yield serializers.serialize(
      object.placeholders,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    if (object.conditions != null) {
      yield r'conditions';
      yield serializers.serialize(
        object.conditions,
        specifiedType: const FullType(BuiltList, [FullType(JsonObject)]),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.approvedAt != null) {
      yield r'approvedAt';
      yield serializers.serialize(
        object.approvedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.createdBy != null) {
      yield r'createdBy';
      yield serializers.serialize(
        object.createdBy,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.updatedBy != null) {
      yield r'updatedBy';
      yield serializers.serialize(
        object.updatedBy,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.approvedBy != null) {
      yield r'approvedBy';
      yield serializers.serialize(
        object.approvedBy,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TemplateRecord object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TemplateRecordBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'templateGroupId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.templateGroupId = valueDes;
          break;
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
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.version = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
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
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'approvedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.approvedAt = valueDes;
          break;
        case r'createdBy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.createdBy = valueDes;
          break;
        case r'updatedBy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.updatedBy = valueDes;
          break;
        case r'approvedBy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approvedBy = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TemplateRecord deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TemplateRecordBuilder();
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

