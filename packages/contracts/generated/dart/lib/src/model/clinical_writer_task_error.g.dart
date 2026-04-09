// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_writer_task_error.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClinicalWriterTaskError extends ClinicalWriterTaskError {
  @override
  final bool retryable;
  @override
  final String userMessage;
  @override
  final String? detail;

  factory _$ClinicalWriterTaskError(
          [void Function(ClinicalWriterTaskErrorBuilder)? updates]) =>
      (ClinicalWriterTaskErrorBuilder()..update(updates))._build();

  _$ClinicalWriterTaskError._(
      {required this.retryable, required this.userMessage, this.detail})
      : super._();
  @override
  ClinicalWriterTaskError rebuild(
          void Function(ClinicalWriterTaskErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClinicalWriterTaskErrorBuilder toBuilder() =>
      ClinicalWriterTaskErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClinicalWriterTaskError &&
        retryable == other.retryable &&
        userMessage == other.userMessage &&
        detail == other.detail;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, retryable.hashCode);
    _$hash = $jc(_$hash, userMessage.hashCode);
    _$hash = $jc(_$hash, detail.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClinicalWriterTaskError')
          ..add('retryable', retryable)
          ..add('userMessage', userMessage)
          ..add('detail', detail))
        .toString();
  }
}

class ClinicalWriterTaskErrorBuilder
    implements
        Builder<ClinicalWriterTaskError, ClinicalWriterTaskErrorBuilder> {
  _$ClinicalWriterTaskError? _$v;

  bool? _retryable;
  bool? get retryable => _$this._retryable;
  set retryable(bool? retryable) => _$this._retryable = retryable;

  String? _userMessage;
  String? get userMessage => _$this._userMessage;
  set userMessage(String? userMessage) => _$this._userMessage = userMessage;

  String? _detail;
  String? get detail => _$this._detail;
  set detail(String? detail) => _$this._detail = detail;

  ClinicalWriterTaskErrorBuilder() {
    ClinicalWriterTaskError._defaults(this);
  }

  ClinicalWriterTaskErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _retryable = $v.retryable;
      _userMessage = $v.userMessage;
      _detail = $v.detail;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClinicalWriterTaskError other) {
    _$v = other as _$ClinicalWriterTaskError;
  }

  @override
  void update(void Function(ClinicalWriterTaskErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClinicalWriterTaskError build() => _build();

  _$ClinicalWriterTaskError _build() {
    final _$result = _$v ??
        _$ClinicalWriterTaskError._(
          retryable: BuiltValueNullFieldError.checkNotNull(
              retryable, r'ClinicalWriterTaskError', 'retryable'),
          userMessage: BuiltValueNullFieldError.checkNotNull(
              userMessage, r'ClinicalWriterTaskError', 'userMessage'),
          detail: detail,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
