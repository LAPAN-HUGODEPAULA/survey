// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_writer_task_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClinicalWriterTaskResponse extends ClinicalWriterTaskResponse {
  @override
  final String taskId;
  @override
  final String status;
  @override
  final AIProgress aiProgress;
  @override
  final AgentResponse? result;
  @override
  final ClinicalWriterTaskError? error;

  factory _$ClinicalWriterTaskResponse(
          [void Function(ClinicalWriterTaskResponseBuilder)? updates]) =>
      (ClinicalWriterTaskResponseBuilder()..update(updates))._build();

  _$ClinicalWriterTaskResponse._(
      {required this.taskId,
      required this.status,
      required this.aiProgress,
      this.result,
      this.error})
      : super._();
  @override
  ClinicalWriterTaskResponse rebuild(
          void Function(ClinicalWriterTaskResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClinicalWriterTaskResponseBuilder toBuilder() =>
      ClinicalWriterTaskResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClinicalWriterTaskResponse &&
        taskId == other.taskId &&
        status == other.status &&
        aiProgress == other.aiProgress &&
        result == other.result &&
        error == other.error;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taskId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, aiProgress.hashCode);
    _$hash = $jc(_$hash, result.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClinicalWriterTaskResponse')
          ..add('taskId', taskId)
          ..add('status', status)
          ..add('aiProgress', aiProgress)
          ..add('result', result)
          ..add('error', error))
        .toString();
  }
}

class ClinicalWriterTaskResponseBuilder
    implements
        Builder<ClinicalWriterTaskResponse, ClinicalWriterTaskResponseBuilder> {
  _$ClinicalWriterTaskResponse? _$v;

  String? _taskId;
  String? get taskId => _$this._taskId;
  set taskId(String? taskId) => _$this._taskId = taskId;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  AIProgressBuilder? _aiProgress;
  AIProgressBuilder get aiProgress =>
      _$this._aiProgress ??= AIProgressBuilder();
  set aiProgress(AIProgressBuilder? aiProgress) =>
      _$this._aiProgress = aiProgress;

  AgentResponse? _result;
  AgentResponse? get result => _$this._result;
  set result(AgentResponse? result) => _$this._result = result;

  ClinicalWriterTaskErrorBuilder? _error;
  ClinicalWriterTaskErrorBuilder get error =>
      _$this._error ??= ClinicalWriterTaskErrorBuilder();
  set error(ClinicalWriterTaskErrorBuilder? error) => _$this._error = error;

  ClinicalWriterTaskResponseBuilder() {
    ClinicalWriterTaskResponse._defaults(this);
  }

  ClinicalWriterTaskResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskId = $v.taskId;
      _status = $v.status;
      _aiProgress = $v.aiProgress.toBuilder();
      _result = $v.result;
      _error = $v.error?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClinicalWriterTaskResponse other) {
    _$v = other as _$ClinicalWriterTaskResponse;
  }

  @override
  void update(void Function(ClinicalWriterTaskResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClinicalWriterTaskResponse build() => _build();

  _$ClinicalWriterTaskResponse _build() {
    _$ClinicalWriterTaskResponse _$result;
    try {
      _$result = _$v ??
          _$ClinicalWriterTaskResponse._(
            taskId: BuiltValueNullFieldError.checkNotNull(
                taskId, r'ClinicalWriterTaskResponse', 'taskId'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'ClinicalWriterTaskResponse', 'status'),
            aiProgress: aiProgress.build(),
            result: result,
            error: _error?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'aiProgress';
        aiProgress.build();

        _$failedField = 'error';
        _error?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ClinicalWriterTaskResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
