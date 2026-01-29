// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_writer_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ClinicalWriterRequestInputTypeEnum
    _$clinicalWriterRequestInputTypeEnum_consult =
    const ClinicalWriterRequestInputTypeEnum._('consult');
const ClinicalWriterRequestInputTypeEnum
    _$clinicalWriterRequestInputTypeEnum_survey7 =
    const ClinicalWriterRequestInputTypeEnum._('survey7');
const ClinicalWriterRequestInputTypeEnum
    _$clinicalWriterRequestInputTypeEnum_fullIntake =
    const ClinicalWriterRequestInputTypeEnum._('fullIntake');

ClinicalWriterRequestInputTypeEnum _$clinicalWriterRequestInputTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'consult':
      return _$clinicalWriterRequestInputTypeEnum_consult;
    case 'survey7':
      return _$clinicalWriterRequestInputTypeEnum_survey7;
    case 'fullIntake':
      return _$clinicalWriterRequestInputTypeEnum_fullIntake;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ClinicalWriterRequestInputTypeEnum>
    _$clinicalWriterRequestInputTypeEnumValues = BuiltSet<
        ClinicalWriterRequestInputTypeEnum>(const <ClinicalWriterRequestInputTypeEnum>[
  _$clinicalWriterRequestInputTypeEnum_consult,
  _$clinicalWriterRequestInputTypeEnum_survey7,
  _$clinicalWriterRequestInputTypeEnum_fullIntake,
]);

const ClinicalWriterRequestOutputFormatEnum
    _$clinicalWriterRequestOutputFormatEnum_reportJson =
    const ClinicalWriterRequestOutputFormatEnum._('reportJson');

ClinicalWriterRequestOutputFormatEnum
    _$clinicalWriterRequestOutputFormatEnumValueOf(String name) {
  switch (name) {
    case 'reportJson':
      return _$clinicalWriterRequestOutputFormatEnum_reportJson;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ClinicalWriterRequestOutputFormatEnum>
    _$clinicalWriterRequestOutputFormatEnumValues = BuiltSet<
        ClinicalWriterRequestOutputFormatEnum>(const <ClinicalWriterRequestOutputFormatEnum>[
  _$clinicalWriterRequestOutputFormatEnum_reportJson,
]);

Serializer<ClinicalWriterRequestInputTypeEnum>
    _$clinicalWriterRequestInputTypeEnumSerializer =
    _$ClinicalWriterRequestInputTypeEnumSerializer();
Serializer<ClinicalWriterRequestOutputFormatEnum>
    _$clinicalWriterRequestOutputFormatEnumSerializer =
    _$ClinicalWriterRequestOutputFormatEnumSerializer();

class _$ClinicalWriterRequestInputTypeEnumSerializer
    implements PrimitiveSerializer<ClinicalWriterRequestInputTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'consult': 'consult',
    'survey7': 'survey7',
    'fullIntake': 'full_intake',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'consult': 'consult',
    'survey7': 'survey7',
    'full_intake': 'fullIntake',
  };

  @override
  final Iterable<Type> types = const <Type>[ClinicalWriterRequestInputTypeEnum];
  @override
  final String wireName = 'ClinicalWriterRequestInputTypeEnum';

  @override
  Object serialize(
          Serializers serializers, ClinicalWriterRequestInputTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ClinicalWriterRequestInputTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ClinicalWriterRequestInputTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ClinicalWriterRequestOutputFormatEnumSerializer
    implements PrimitiveSerializer<ClinicalWriterRequestOutputFormatEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'reportJson': 'report_json',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'report_json': 'reportJson',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ClinicalWriterRequestOutputFormatEnum
  ];
  @override
  final String wireName = 'ClinicalWriterRequestOutputFormatEnum';

  @override
  Object serialize(
          Serializers serializers, ClinicalWriterRequestOutputFormatEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ClinicalWriterRequestOutputFormatEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ClinicalWriterRequestOutputFormatEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ClinicalWriterRequest extends ClinicalWriterRequest {
  @override
  final ClinicalWriterRequestInputTypeEnum inputType;
  @override
  final String content;
  @override
  final String locale;
  @override
  final String promptKey;
  @override
  final ClinicalWriterRequestOutputFormatEnum outputFormat;
  @override
  final ClinicalWriterRequestMetadata metadata;

  factory _$ClinicalWriterRequest(
          [void Function(ClinicalWriterRequestBuilder)? updates]) =>
      (ClinicalWriterRequestBuilder()..update(updates))._build();

  _$ClinicalWriterRequest._(
      {required this.inputType,
      required this.content,
      required this.locale,
      required this.promptKey,
      required this.outputFormat,
      required this.metadata})
      : super._();
  @override
  ClinicalWriterRequest rebuild(
          void Function(ClinicalWriterRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClinicalWriterRequestBuilder toBuilder() =>
      ClinicalWriterRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClinicalWriterRequest &&
        inputType == other.inputType &&
        content == other.content &&
        locale == other.locale &&
        promptKey == other.promptKey &&
        outputFormat == other.outputFormat &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, inputType.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, locale.hashCode);
    _$hash = $jc(_$hash, promptKey.hashCode);
    _$hash = $jc(_$hash, outputFormat.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClinicalWriterRequest')
          ..add('inputType', inputType)
          ..add('content', content)
          ..add('locale', locale)
          ..add('promptKey', promptKey)
          ..add('outputFormat', outputFormat)
          ..add('metadata', metadata))
        .toString();
  }
}

class ClinicalWriterRequestBuilder
    implements Builder<ClinicalWriterRequest, ClinicalWriterRequestBuilder> {
  _$ClinicalWriterRequest? _$v;

  ClinicalWriterRequestInputTypeEnum? _inputType;
  ClinicalWriterRequestInputTypeEnum? get inputType => _$this._inputType;
  set inputType(ClinicalWriterRequestInputTypeEnum? inputType) =>
      _$this._inputType = inputType;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  String? _locale;
  String? get locale => _$this._locale;
  set locale(String? locale) => _$this._locale = locale;

  String? _promptKey;
  String? get promptKey => _$this._promptKey;
  set promptKey(String? promptKey) => _$this._promptKey = promptKey;

  ClinicalWriterRequestOutputFormatEnum? _outputFormat;
  ClinicalWriterRequestOutputFormatEnum? get outputFormat =>
      _$this._outputFormat;
  set outputFormat(ClinicalWriterRequestOutputFormatEnum? outputFormat) =>
      _$this._outputFormat = outputFormat;

  ClinicalWriterRequestMetadataBuilder? _metadata;
  ClinicalWriterRequestMetadataBuilder get metadata =>
      _$this._metadata ??= ClinicalWriterRequestMetadataBuilder();
  set metadata(ClinicalWriterRequestMetadataBuilder? metadata) =>
      _$this._metadata = metadata;

  ClinicalWriterRequestBuilder() {
    ClinicalWriterRequest._defaults(this);
  }

  ClinicalWriterRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _inputType = $v.inputType;
      _content = $v.content;
      _locale = $v.locale;
      _promptKey = $v.promptKey;
      _outputFormat = $v.outputFormat;
      _metadata = $v.metadata.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClinicalWriterRequest other) {
    _$v = other as _$ClinicalWriterRequest;
  }

  @override
  void update(void Function(ClinicalWriterRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClinicalWriterRequest build() => _build();

  _$ClinicalWriterRequest _build() {
    _$ClinicalWriterRequest _$result;
    try {
      _$result = _$v ??
          _$ClinicalWriterRequest._(
            inputType: BuiltValueNullFieldError.checkNotNull(
                inputType, r'ClinicalWriterRequest', 'inputType'),
            content: BuiltValueNullFieldError.checkNotNull(
                content, r'ClinicalWriterRequest', 'content'),
            locale: BuiltValueNullFieldError.checkNotNull(
                locale, r'ClinicalWriterRequest', 'locale'),
            promptKey: BuiltValueNullFieldError.checkNotNull(
                promptKey, r'ClinicalWriterRequest', 'promptKey'),
            outputFormat: BuiltValueNullFieldError.checkNotNull(
                outputFormat, r'ClinicalWriterRequest', 'outputFormat'),
            metadata: metadata.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metadata';
        metadata.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ClinicalWriterRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
