// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TranscriptionResponse extends TranscriptionResponse {
  @override
  final String requestId;
  @override
  final String text;
  @override
  final double? confidence;
  @override
  final BuiltList<TranscriptionSegment>? segments;
  @override
  final int processingTimeMs;
  @override
  final String provider;
  @override
  final String language;
  @override
  final BuiltList<String>? warnings;
  @override
  final BuiltMap<String, JsonObject?>? metadata;

  factory _$TranscriptionResponse(
          [void Function(TranscriptionResponseBuilder)? updates]) =>
      (TranscriptionResponseBuilder()..update(updates))._build();

  _$TranscriptionResponse._(
      {required this.requestId,
      required this.text,
      this.confidence,
      this.segments,
      required this.processingTimeMs,
      required this.provider,
      required this.language,
      this.warnings,
      this.metadata})
      : super._();
  @override
  TranscriptionResponse rebuild(
          void Function(TranscriptionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TranscriptionResponseBuilder toBuilder() =>
      TranscriptionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TranscriptionResponse &&
        requestId == other.requestId &&
        text == other.text &&
        confidence == other.confidence &&
        segments == other.segments &&
        processingTimeMs == other.processingTimeMs &&
        provider == other.provider &&
        language == other.language &&
        warnings == other.warnings &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, confidence.hashCode);
    _$hash = $jc(_$hash, segments.hashCode);
    _$hash = $jc(_$hash, processingTimeMs.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, language.hashCode);
    _$hash = $jc(_$hash, warnings.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TranscriptionResponse')
          ..add('requestId', requestId)
          ..add('text', text)
          ..add('confidence', confidence)
          ..add('segments', segments)
          ..add('processingTimeMs', processingTimeMs)
          ..add('provider', provider)
          ..add('language', language)
          ..add('warnings', warnings)
          ..add('metadata', metadata))
        .toString();
  }
}

class TranscriptionResponseBuilder
    implements Builder<TranscriptionResponse, TranscriptionResponseBuilder> {
  _$TranscriptionResponse? _$v;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  double? _confidence;
  double? get confidence => _$this._confidence;
  set confidence(double? confidence) => _$this._confidence = confidence;

  ListBuilder<TranscriptionSegment>? _segments;
  ListBuilder<TranscriptionSegment> get segments =>
      _$this._segments ??= ListBuilder<TranscriptionSegment>();
  set segments(ListBuilder<TranscriptionSegment>? segments) =>
      _$this._segments = segments;

  int? _processingTimeMs;
  int? get processingTimeMs => _$this._processingTimeMs;
  set processingTimeMs(int? processingTimeMs) =>
      _$this._processingTimeMs = processingTimeMs;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  String? _language;
  String? get language => _$this._language;
  set language(String? language) => _$this._language = language;

  ListBuilder<String>? _warnings;
  ListBuilder<String> get warnings =>
      _$this._warnings ??= ListBuilder<String>();
  set warnings(ListBuilder<String>? warnings) => _$this._warnings = warnings;

  MapBuilder<String, JsonObject?>? _metadata;
  MapBuilder<String, JsonObject?> get metadata =>
      _$this._metadata ??= MapBuilder<String, JsonObject?>();
  set metadata(MapBuilder<String, JsonObject?>? metadata) =>
      _$this._metadata = metadata;

  TranscriptionResponseBuilder() {
    TranscriptionResponse._defaults(this);
  }

  TranscriptionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _text = $v.text;
      _confidence = $v.confidence;
      _segments = $v.segments?.toBuilder();
      _processingTimeMs = $v.processingTimeMs;
      _provider = $v.provider;
      _language = $v.language;
      _warnings = $v.warnings?.toBuilder();
      _metadata = $v.metadata?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TranscriptionResponse other) {
    _$v = other as _$TranscriptionResponse;
  }

  @override
  void update(void Function(TranscriptionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TranscriptionResponse build() => _build();

  _$TranscriptionResponse _build() {
    _$TranscriptionResponse _$result;
    try {
      _$result = _$v ??
          _$TranscriptionResponse._(
            requestId: BuiltValueNullFieldError.checkNotNull(
                requestId, r'TranscriptionResponse', 'requestId'),
            text: BuiltValueNullFieldError.checkNotNull(
                text, r'TranscriptionResponse', 'text'),
            confidence: confidence,
            segments: _segments?.build(),
            processingTimeMs: BuiltValueNullFieldError.checkNotNull(
                processingTimeMs, r'TranscriptionResponse', 'processingTimeMs'),
            provider: BuiltValueNullFieldError.checkNotNull(
                provider, r'TranscriptionResponse', 'provider'),
            language: BuiltValueNullFieldError.checkNotNull(
                language, r'TranscriptionResponse', 'language'),
            warnings: _warnings?.build(),
            metadata: _metadata?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'segments';
        _segments?.build();

        _$failedField = 'warnings';
        _warnings?.build();
        _$failedField = 'metadata';
        _metadata?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TranscriptionResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
