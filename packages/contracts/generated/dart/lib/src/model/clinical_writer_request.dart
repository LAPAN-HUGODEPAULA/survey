//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:survey_backend_api/src/model/clinical_writer_request_metadata.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'clinical_writer_request.g.dart';

/// ClinicalWriterRequest
///
/// Properties:
/// * [inputType] 
/// * [content] 
/// * [locale] 
/// * [promptKey] 
/// * [outputFormat] 
/// * [metadata] 
@BuiltValue()
abstract class ClinicalWriterRequest implements Built<ClinicalWriterRequest, ClinicalWriterRequestBuilder> {
  @BuiltValueField(wireName: r'input_type')
  ClinicalWriterRequestInputTypeEnum get inputType;
  // enum inputTypeEnum {  consult,  survey7,  full_intake,  };

  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'locale')
  String get locale;

  @BuiltValueField(wireName: r'prompt_key')
  String get promptKey;

  @BuiltValueField(wireName: r'output_format')
  ClinicalWriterRequestOutputFormatEnum get outputFormat;
  // enum outputFormatEnum {  report_json,  };

  @BuiltValueField(wireName: r'metadata')
  ClinicalWriterRequestMetadata get metadata;

  ClinicalWriterRequest._();

  factory ClinicalWriterRequest([void updates(ClinicalWriterRequestBuilder b)]) = _$ClinicalWriterRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClinicalWriterRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClinicalWriterRequest> get serializer => _$ClinicalWriterRequestSerializer();
}

class _$ClinicalWriterRequestSerializer implements PrimitiveSerializer<ClinicalWriterRequest> {
  @override
  final Iterable<Type> types = const [ClinicalWriterRequest, _$ClinicalWriterRequest];

  @override
  final String wireName = r'ClinicalWriterRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClinicalWriterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'input_type';
    yield serializers.serialize(
      object.inputType,
      specifiedType: const FullType(ClinicalWriterRequestInputTypeEnum),
    );
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'locale';
    yield serializers.serialize(
      object.locale,
      specifiedType: const FullType(String),
    );
    yield r'prompt_key';
    yield serializers.serialize(
      object.promptKey,
      specifiedType: const FullType(String),
    );
    yield r'output_format';
    yield serializers.serialize(
      object.outputFormat,
      specifiedType: const FullType(ClinicalWriterRequestOutputFormatEnum),
    );
    yield r'metadata';
    yield serializers.serialize(
      object.metadata,
      specifiedType: const FullType(ClinicalWriterRequestMetadata),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ClinicalWriterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClinicalWriterRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'input_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ClinicalWriterRequestInputTypeEnum),
          ) as ClinicalWriterRequestInputTypeEnum;
          result.inputType = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'locale':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.locale = valueDes;
          break;
        case r'prompt_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.promptKey = valueDes;
          break;
        case r'output_format':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ClinicalWriterRequestOutputFormatEnum),
          ) as ClinicalWriterRequestOutputFormatEnum;
          result.outputFormat = valueDes;
          break;
        case r'metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ClinicalWriterRequestMetadata),
          ) as ClinicalWriterRequestMetadata;
          result.metadata.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClinicalWriterRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClinicalWriterRequestBuilder();
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

class ClinicalWriterRequestInputTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'consult')
  static const ClinicalWriterRequestInputTypeEnum consult = _$clinicalWriterRequestInputTypeEnum_consult;
  @BuiltValueEnumConst(wireName: r'survey7')
  static const ClinicalWriterRequestInputTypeEnum survey7 = _$clinicalWriterRequestInputTypeEnum_survey7;
  @BuiltValueEnumConst(wireName: r'full_intake')
  static const ClinicalWriterRequestInputTypeEnum fullIntake = _$clinicalWriterRequestInputTypeEnum_fullIntake;

  static Serializer<ClinicalWriterRequestInputTypeEnum> get serializer => _$clinicalWriterRequestInputTypeEnumSerializer;

  const ClinicalWriterRequestInputTypeEnum._(String name): super(name);

  static BuiltSet<ClinicalWriterRequestInputTypeEnum> get values => _$clinicalWriterRequestInputTypeEnumValues;
  static ClinicalWriterRequestInputTypeEnum valueOf(String name) => _$clinicalWriterRequestInputTypeEnumValueOf(name);
}

class ClinicalWriterRequestOutputFormatEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'report_json')
  static const ClinicalWriterRequestOutputFormatEnum reportJson = _$clinicalWriterRequestOutputFormatEnum_reportJson;

  static Serializer<ClinicalWriterRequestOutputFormatEnum> get serializer => _$clinicalWriterRequestOutputFormatEnumSerializer;

  const ClinicalWriterRequestOutputFormatEnum._(String name): super(name);

  static BuiltSet<ClinicalWriterRequestOutputFormatEnum> get values => _$clinicalWriterRequestOutputFormatEnumValues;
  static ClinicalWriterRequestOutputFormatEnum valueOf(String name) => _$clinicalWriterRequestOutputFormatEnumValueOf(name);
}

