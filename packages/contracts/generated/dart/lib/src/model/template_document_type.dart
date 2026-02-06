//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'template_document_type.g.dart';

class TemplateDocumentType extends EnumClass {

  @BuiltValueEnumConst(wireName: r'consultation_record')
  static const TemplateDocumentType consultationRecord = _$consultationRecord;
  @BuiltValueEnumConst(wireName: r'prescription')
  static const TemplateDocumentType prescription = _$prescription;
  @BuiltValueEnumConst(wireName: r'referral')
  static const TemplateDocumentType referral = _$referral;
  @BuiltValueEnumConst(wireName: r'certificate')
  static const TemplateDocumentType certificate = _$certificate;
  @BuiltValueEnumConst(wireName: r'technical_report')
  static const TemplateDocumentType technicalReport = _$technicalReport;
  @BuiltValueEnumConst(wireName: r'clinical_progress')
  static const TemplateDocumentType clinicalProgress = _$clinicalProgress;

  static Serializer<TemplateDocumentType> get serializer => _$templateDocumentTypeSerializer;

  const TemplateDocumentType._(String name): super(name);

  static BuiltSet<TemplateDocumentType> get values => _$values;
  static TemplateDocumentType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class TemplateDocumentTypeMixin = Object with _$TemplateDocumentTypeMixin;

