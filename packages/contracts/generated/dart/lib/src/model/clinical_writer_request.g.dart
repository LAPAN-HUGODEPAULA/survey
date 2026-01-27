// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_writer_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClinicalWriterRequest extends ClinicalWriterRequest {
  @override
  final String content;

  factory _$ClinicalWriterRequest(
          [void Function(ClinicalWriterRequestBuilder)? updates]) =>
      (ClinicalWriterRequestBuilder()..update(updates))._build();

  _$ClinicalWriterRequest._({required this.content}) : super._();
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
    return other is ClinicalWriterRequest && content == other.content;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClinicalWriterRequest')
          ..add('content', content))
        .toString();
  }
}

class ClinicalWriterRequestBuilder
    implements Builder<ClinicalWriterRequest, ClinicalWriterRequestBuilder> {
  _$ClinicalWriterRequest? _$v;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  ClinicalWriterRequestBuilder() {
    ClinicalWriterRequest._defaults(this);
  }

  ClinicalWriterRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
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
    final _$result = _$v ??
        _$ClinicalWriterRequest._(
          content: BuiltValueNullFieldError.checkNotNull(
              content, r'ClinicalWriterRequest', 'content'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
