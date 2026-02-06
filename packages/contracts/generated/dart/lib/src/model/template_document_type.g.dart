// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_document_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TemplateDocumentType _$consultationRecord =
    const TemplateDocumentType._('consultationRecord');
const TemplateDocumentType _$prescription =
    const TemplateDocumentType._('prescription');
const TemplateDocumentType _$referral =
    const TemplateDocumentType._('referral');
const TemplateDocumentType _$certificate =
    const TemplateDocumentType._('certificate');
const TemplateDocumentType _$technicalReport =
    const TemplateDocumentType._('technicalReport');
const TemplateDocumentType _$clinicalProgress =
    const TemplateDocumentType._('clinicalProgress');

TemplateDocumentType _$valueOf(String name) {
  switch (name) {
    case 'consultationRecord':
      return _$consultationRecord;
    case 'prescription':
      return _$prescription;
    case 'referral':
      return _$referral;
    case 'certificate':
      return _$certificate;
    case 'technicalReport':
      return _$technicalReport;
    case 'clinicalProgress':
      return _$clinicalProgress;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TemplateDocumentType> _$values =
    BuiltSet<TemplateDocumentType>(const <TemplateDocumentType>[
  _$consultationRecord,
  _$prescription,
  _$referral,
  _$certificate,
  _$technicalReport,
  _$clinicalProgress,
]);

class _$TemplateDocumentTypeMeta {
  const _$TemplateDocumentTypeMeta();
  TemplateDocumentType get consultationRecord => _$consultationRecord;
  TemplateDocumentType get prescription => _$prescription;
  TemplateDocumentType get referral => _$referral;
  TemplateDocumentType get certificate => _$certificate;
  TemplateDocumentType get technicalReport => _$technicalReport;
  TemplateDocumentType get clinicalProgress => _$clinicalProgress;
  TemplateDocumentType valueOf(String name) => _$valueOf(name);
  BuiltSet<TemplateDocumentType> get values => _$values;
}

abstract class _$TemplateDocumentTypeMixin {
  // ignore: non_constant_identifier_names
  _$TemplateDocumentTypeMeta get TemplateDocumentType =>
      const _$TemplateDocumentTypeMeta();
}

Serializer<TemplateDocumentType> _$templateDocumentTypeSerializer =
    _$TemplateDocumentTypeSerializer();

class _$TemplateDocumentTypeSerializer
    implements PrimitiveSerializer<TemplateDocumentType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'consultationRecord': 'consultation_record',
    'prescription': 'prescription',
    'referral': 'referral',
    'certificate': 'certificate',
    'technicalReport': 'technical_report',
    'clinicalProgress': 'clinical_progress',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'consultation_record': 'consultationRecord',
    'prescription': 'prescription',
    'referral': 'referral',
    'certificate': 'certificate',
    'technical_report': 'technicalReport',
    'clinical_progress': 'clinicalProgress',
  };

  @override
  final Iterable<Type> types = const <Type>[TemplateDocumentType];
  @override
  final String wireName = 'TemplateDocumentType';

  @override
  Object serialize(Serializers serializers, TemplateDocumentType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TemplateDocumentType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TemplateDocumentType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
