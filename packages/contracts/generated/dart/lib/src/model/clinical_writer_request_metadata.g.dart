// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_writer_request_metadata.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClinicalWriterRequestMetadata extends ClinicalWriterRequestMetadata {
  @override
  final String? sourceApp;
  @override
  final String? requestId;
  @override
  final String? patientRef;

  factory _$ClinicalWriterRequestMetadata(
          [void Function(ClinicalWriterRequestMetadataBuilder)? updates]) =>
      (ClinicalWriterRequestMetadataBuilder()..update(updates))._build();

  _$ClinicalWriterRequestMetadata._(
      {this.sourceApp, this.requestId, this.patientRef})
      : super._();
  @override
  ClinicalWriterRequestMetadata rebuild(
          void Function(ClinicalWriterRequestMetadataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClinicalWriterRequestMetadataBuilder toBuilder() =>
      ClinicalWriterRequestMetadataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClinicalWriterRequestMetadata &&
        sourceApp == other.sourceApp &&
        requestId == other.requestId &&
        patientRef == other.patientRef;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sourceApp.hashCode);
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, patientRef.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClinicalWriterRequestMetadata')
          ..add('sourceApp', sourceApp)
          ..add('requestId', requestId)
          ..add('patientRef', patientRef))
        .toString();
  }
}

class ClinicalWriterRequestMetadataBuilder
    implements
        Builder<ClinicalWriterRequestMetadata,
            ClinicalWriterRequestMetadataBuilder> {
  _$ClinicalWriterRequestMetadata? _$v;

  String? _sourceApp;
  String? get sourceApp => _$this._sourceApp;
  set sourceApp(String? sourceApp) => _$this._sourceApp = sourceApp;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  String? _patientRef;
  String? get patientRef => _$this._patientRef;
  set patientRef(String? patientRef) => _$this._patientRef = patientRef;

  ClinicalWriterRequestMetadataBuilder() {
    ClinicalWriterRequestMetadata._defaults(this);
  }

  ClinicalWriterRequestMetadataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sourceApp = $v.sourceApp;
      _requestId = $v.requestId;
      _patientRef = $v.patientRef;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClinicalWriterRequestMetadata other) {
    _$v = other as _$ClinicalWriterRequestMetadata;
  }

  @override
  void update(void Function(ClinicalWriterRequestMetadataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClinicalWriterRequestMetadata build() => _build();

  _$ClinicalWriterRequestMetadata _build() {
    final _$result = _$v ??
        _$ClinicalWriterRequestMetadata._(
          sourceApp: sourceApp,
          requestId: requestId,
          patientRef: patientRef,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
