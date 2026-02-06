// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_segment.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TranscriptionSegment extends TranscriptionSegment {
  @override
  final double startSeconds;
  @override
  final double endSeconds;
  @override
  final String text;
  @override
  final double? confidence;

  factory _$TranscriptionSegment(
          [void Function(TranscriptionSegmentBuilder)? updates]) =>
      (TranscriptionSegmentBuilder()..update(updates))._build();

  _$TranscriptionSegment._(
      {required this.startSeconds,
      required this.endSeconds,
      required this.text,
      this.confidence})
      : super._();
  @override
  TranscriptionSegment rebuild(
          void Function(TranscriptionSegmentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TranscriptionSegmentBuilder toBuilder() =>
      TranscriptionSegmentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TranscriptionSegment &&
        startSeconds == other.startSeconds &&
        endSeconds == other.endSeconds &&
        text == other.text &&
        confidence == other.confidence;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, startSeconds.hashCode);
    _$hash = $jc(_$hash, endSeconds.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, confidence.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TranscriptionSegment')
          ..add('startSeconds', startSeconds)
          ..add('endSeconds', endSeconds)
          ..add('text', text)
          ..add('confidence', confidence))
        .toString();
  }
}

class TranscriptionSegmentBuilder
    implements Builder<TranscriptionSegment, TranscriptionSegmentBuilder> {
  _$TranscriptionSegment? _$v;

  double? _startSeconds;
  double? get startSeconds => _$this._startSeconds;
  set startSeconds(double? startSeconds) => _$this._startSeconds = startSeconds;

  double? _endSeconds;
  double? get endSeconds => _$this._endSeconds;
  set endSeconds(double? endSeconds) => _$this._endSeconds = endSeconds;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  double? _confidence;
  double? get confidence => _$this._confidence;
  set confidence(double? confidence) => _$this._confidence = confidence;

  TranscriptionSegmentBuilder() {
    TranscriptionSegment._defaults(this);
  }

  TranscriptionSegmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _startSeconds = $v.startSeconds;
      _endSeconds = $v.endSeconds;
      _text = $v.text;
      _confidence = $v.confidence;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TranscriptionSegment other) {
    _$v = other as _$TranscriptionSegment;
  }

  @override
  void update(void Function(TranscriptionSegmentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TranscriptionSegment build() => _build();

  _$TranscriptionSegment _build() {
    final _$result = _$v ??
        _$TranscriptionSegment._(
          startSeconds: BuiltValueNullFieldError.checkNotNull(
              startSeconds, r'TranscriptionSegment', 'startSeconds'),
          endSeconds: BuiltValueNullFieldError.checkNotNull(
              endSeconds, r'TranscriptionSegment', 'endSeconds'),
          text: BuiltValueNullFieldError.checkNotNull(
              text, r'TranscriptionSegment', 'text'),
          confidence: confidence,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
