// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TranscriptionRequest extends TranscriptionRequest {
  @override
  final String audioBase64;
  @override
  final String audioFormat;
  @override
  final int? sampleRate;
  @override
  final int? channels;
  @override
  final double? durationSeconds;
  @override
  final String? language;
  @override
  final bool? clinicalMode;
  @override
  final double? confidenceThreshold;
  @override
  final String? previewText;
  @override
  final BuiltMap<String, JsonObject?>? metadata;

  factory _$TranscriptionRequest(
          [void Function(TranscriptionRequestBuilder)? updates]) =>
      (TranscriptionRequestBuilder()..update(updates))._build();

  _$TranscriptionRequest._(
      {required this.audioBase64,
      required this.audioFormat,
      this.sampleRate,
      this.channels,
      this.durationSeconds,
      this.language,
      this.clinicalMode,
      this.confidenceThreshold,
      this.previewText,
      this.metadata})
      : super._();
  @override
  TranscriptionRequest rebuild(
          void Function(TranscriptionRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TranscriptionRequestBuilder toBuilder() =>
      TranscriptionRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TranscriptionRequest &&
        audioBase64 == other.audioBase64 &&
        audioFormat == other.audioFormat &&
        sampleRate == other.sampleRate &&
        channels == other.channels &&
        durationSeconds == other.durationSeconds &&
        language == other.language &&
        clinicalMode == other.clinicalMode &&
        confidenceThreshold == other.confidenceThreshold &&
        previewText == other.previewText &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, audioBase64.hashCode);
    _$hash = $jc(_$hash, audioFormat.hashCode);
    _$hash = $jc(_$hash, sampleRate.hashCode);
    _$hash = $jc(_$hash, channels.hashCode);
    _$hash = $jc(_$hash, durationSeconds.hashCode);
    _$hash = $jc(_$hash, language.hashCode);
    _$hash = $jc(_$hash, clinicalMode.hashCode);
    _$hash = $jc(_$hash, confidenceThreshold.hashCode);
    _$hash = $jc(_$hash, previewText.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TranscriptionRequest')
          ..add('audioBase64', audioBase64)
          ..add('audioFormat', audioFormat)
          ..add('sampleRate', sampleRate)
          ..add('channels', channels)
          ..add('durationSeconds', durationSeconds)
          ..add('language', language)
          ..add('clinicalMode', clinicalMode)
          ..add('confidenceThreshold', confidenceThreshold)
          ..add('previewText', previewText)
          ..add('metadata', metadata))
        .toString();
  }
}

class TranscriptionRequestBuilder
    implements Builder<TranscriptionRequest, TranscriptionRequestBuilder> {
  _$TranscriptionRequest? _$v;

  String? _audioBase64;
  String? get audioBase64 => _$this._audioBase64;
  set audioBase64(String? audioBase64) => _$this._audioBase64 = audioBase64;

  String? _audioFormat;
  String? get audioFormat => _$this._audioFormat;
  set audioFormat(String? audioFormat) => _$this._audioFormat = audioFormat;

  int? _sampleRate;
  int? get sampleRate => _$this._sampleRate;
  set sampleRate(int? sampleRate) => _$this._sampleRate = sampleRate;

  int? _channels;
  int? get channels => _$this._channels;
  set channels(int? channels) => _$this._channels = channels;

  double? _durationSeconds;
  double? get durationSeconds => _$this._durationSeconds;
  set durationSeconds(double? durationSeconds) =>
      _$this._durationSeconds = durationSeconds;

  String? _language;
  String? get language => _$this._language;
  set language(String? language) => _$this._language = language;

  bool? _clinicalMode;
  bool? get clinicalMode => _$this._clinicalMode;
  set clinicalMode(bool? clinicalMode) => _$this._clinicalMode = clinicalMode;

  double? _confidenceThreshold;
  double? get confidenceThreshold => _$this._confidenceThreshold;
  set confidenceThreshold(double? confidenceThreshold) =>
      _$this._confidenceThreshold = confidenceThreshold;

  String? _previewText;
  String? get previewText => _$this._previewText;
  set previewText(String? previewText) => _$this._previewText = previewText;

  MapBuilder<String, JsonObject?>? _metadata;
  MapBuilder<String, JsonObject?> get metadata =>
      _$this._metadata ??= MapBuilder<String, JsonObject?>();
  set metadata(MapBuilder<String, JsonObject?>? metadata) =>
      _$this._metadata = metadata;

  TranscriptionRequestBuilder() {
    TranscriptionRequest._defaults(this);
  }

  TranscriptionRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _audioBase64 = $v.audioBase64;
      _audioFormat = $v.audioFormat;
      _sampleRate = $v.sampleRate;
      _channels = $v.channels;
      _durationSeconds = $v.durationSeconds;
      _language = $v.language;
      _clinicalMode = $v.clinicalMode;
      _confidenceThreshold = $v.confidenceThreshold;
      _previewText = $v.previewText;
      _metadata = $v.metadata?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TranscriptionRequest other) {
    _$v = other as _$TranscriptionRequest;
  }

  @override
  void update(void Function(TranscriptionRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TranscriptionRequest build() => _build();

  _$TranscriptionRequest _build() {
    _$TranscriptionRequest _$result;
    try {
      _$result = _$v ??
          _$TranscriptionRequest._(
            audioBase64: BuiltValueNullFieldError.checkNotNull(
                audioBase64, r'TranscriptionRequest', 'audioBase64'),
            audioFormat: BuiltValueNullFieldError.checkNotNull(
                audioFormat, r'TranscriptionRequest', 'audioFormat'),
            sampleRate: sampleRate,
            channels: channels,
            durationSeconds: durationSeconds,
            language: language,
            clinicalMode: clinicalMode,
            confidenceThreshold: confidenceThreshold,
            previewText: previewText,
            metadata: _metadata?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metadata';
        _metadata?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TranscriptionRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
