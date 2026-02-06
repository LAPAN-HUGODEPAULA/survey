// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_preview_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TemplatePreviewRequest extends TemplatePreviewRequest {
  @override
  final BuiltMap<String, JsonObject?>? sampleData;

  factory _$TemplatePreviewRequest(
          [void Function(TemplatePreviewRequestBuilder)? updates]) =>
      (TemplatePreviewRequestBuilder()..update(updates))._build();

  _$TemplatePreviewRequest._({this.sampleData}) : super._();
  @override
  TemplatePreviewRequest rebuild(
          void Function(TemplatePreviewRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TemplatePreviewRequestBuilder toBuilder() =>
      TemplatePreviewRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TemplatePreviewRequest && sampleData == other.sampleData;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sampleData.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TemplatePreviewRequest')
          ..add('sampleData', sampleData))
        .toString();
  }
}

class TemplatePreviewRequestBuilder
    implements Builder<TemplatePreviewRequest, TemplatePreviewRequestBuilder> {
  _$TemplatePreviewRequest? _$v;

  MapBuilder<String, JsonObject?>? _sampleData;
  MapBuilder<String, JsonObject?> get sampleData =>
      _$this._sampleData ??= MapBuilder<String, JsonObject?>();
  set sampleData(MapBuilder<String, JsonObject?>? sampleData) =>
      _$this._sampleData = sampleData;

  TemplatePreviewRequestBuilder() {
    TemplatePreviewRequest._defaults(this);
  }

  TemplatePreviewRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sampleData = $v.sampleData?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TemplatePreviewRequest other) {
    _$v = other as _$TemplatePreviewRequest;
  }

  @override
  void update(void Function(TemplatePreviewRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TemplatePreviewRequest build() => _build();

  _$TemplatePreviewRequest _build() {
    _$TemplatePreviewRequest _$result;
    try {
      _$result = _$v ??
          _$TemplatePreviewRequest._(
            sampleData: _sampleData?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sampleData';
        _sampleData?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TemplatePreviewRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
