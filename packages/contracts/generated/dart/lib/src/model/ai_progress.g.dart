// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_progress.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AIProgressSeverityEnum _$aIProgressSeverityEnum_info =
    const AIProgressSeverityEnum._('info');
const AIProgressSeverityEnum _$aIProgressSeverityEnum_success =
    const AIProgressSeverityEnum._('success');
const AIProgressSeverityEnum _$aIProgressSeverityEnum_warning =
    const AIProgressSeverityEnum._('warning');
const AIProgressSeverityEnum _$aIProgressSeverityEnum_critical =
    const AIProgressSeverityEnum._('critical');

AIProgressSeverityEnum _$aIProgressSeverityEnumValueOf(String name) {
  switch (name) {
    case 'info':
      return _$aIProgressSeverityEnum_info;
    case 'success':
      return _$aIProgressSeverityEnum_success;
    case 'warning':
      return _$aIProgressSeverityEnum_warning;
    case 'critical':
      return _$aIProgressSeverityEnum_critical;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AIProgressSeverityEnum> _$aIProgressSeverityEnumValues =
    BuiltSet<AIProgressSeverityEnum>(const <AIProgressSeverityEnum>[
  _$aIProgressSeverityEnum_info,
  _$aIProgressSeverityEnum_success,
  _$aIProgressSeverityEnum_warning,
  _$aIProgressSeverityEnum_critical,
]);

Serializer<AIProgressSeverityEnum> _$aIProgressSeverityEnumSerializer =
    _$AIProgressSeverityEnumSerializer();

class _$AIProgressSeverityEnumSerializer
    implements PrimitiveSerializer<AIProgressSeverityEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'info': 'info',
    'success': 'success',
    'warning': 'warning',
    'critical': 'critical',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'info': 'info',
    'success': 'success',
    'warning': 'warning',
    'critical': 'critical',
  };

  @override
  final Iterable<Type> types = const <Type>[AIProgressSeverityEnum];
  @override
  final String wireName = 'AIProgressSeverityEnum';

  @override
  Object serialize(Serializers serializers, AIProgressSeverityEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AIProgressSeverityEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AIProgressSeverityEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AIProgress extends AIProgress {
  @override
  final String? stage;
  @override
  final String? stageLabel;
  @override
  final int? percent;
  @override
  final String? status;
  @override
  final AIProgressSeverityEnum? severity;
  @override
  final bool? retryable;
  @override
  final String? userMessage;
  @override
  final String? updatedAt;

  factory _$AIProgress([void Function(AIProgressBuilder)? updates]) =>
      (AIProgressBuilder()..update(updates))._build();

  _$AIProgress._(
      {this.stage,
      this.stageLabel,
      this.percent,
      this.status,
      this.severity,
      this.retryable,
      this.userMessage,
      this.updatedAt})
      : super._();
  @override
  AIProgress rebuild(void Function(AIProgressBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AIProgressBuilder toBuilder() => AIProgressBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AIProgress &&
        stage == other.stage &&
        stageLabel == other.stageLabel &&
        percent == other.percent &&
        status == other.status &&
        severity == other.severity &&
        retryable == other.retryable &&
        userMessage == other.userMessage &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jc(_$hash, stageLabel.hashCode);
    _$hash = $jc(_$hash, percent.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, severity.hashCode);
    _$hash = $jc(_$hash, retryable.hashCode);
    _$hash = $jc(_$hash, userMessage.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AIProgress')
          ..add('stage', stage)
          ..add('stageLabel', stageLabel)
          ..add('percent', percent)
          ..add('status', status)
          ..add('severity', severity)
          ..add('retryable', retryable)
          ..add('userMessage', userMessage)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class AIProgressBuilder implements Builder<AIProgress, AIProgressBuilder> {
  _$AIProgress? _$v;

  String? _stage;
  String? get stage => _$this._stage;
  set stage(String? stage) => _$this._stage = stage;

  String? _stageLabel;
  String? get stageLabel => _$this._stageLabel;
  set stageLabel(String? stageLabel) => _$this._stageLabel = stageLabel;

  int? _percent;
  int? get percent => _$this._percent;
  set percent(int? percent) => _$this._percent = percent;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  AIProgressSeverityEnum? _severity;
  AIProgressSeverityEnum? get severity => _$this._severity;
  set severity(AIProgressSeverityEnum? severity) => _$this._severity = severity;

  bool? _retryable;
  bool? get retryable => _$this._retryable;
  set retryable(bool? retryable) => _$this._retryable = retryable;

  String? _userMessage;
  String? get userMessage => _$this._userMessage;
  set userMessage(String? userMessage) => _$this._userMessage = userMessage;

  String? _updatedAt;
  String? get updatedAt => _$this._updatedAt;
  set updatedAt(String? updatedAt) => _$this._updatedAt = updatedAt;

  AIProgressBuilder() {
    AIProgress._defaults(this);
  }

  AIProgressBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stage = $v.stage;
      _stageLabel = $v.stageLabel;
      _percent = $v.percent;
      _status = $v.status;
      _severity = $v.severity;
      _retryable = $v.retryable;
      _userMessage = $v.userMessage;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AIProgress other) {
    _$v = other as _$AIProgress;
  }

  @override
  void update(void Function(AIProgressBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AIProgress build() => _build();

  _$AIProgress _build() {
    final _$result = _$v ??
        _$AIProgress._(
          stage: stage,
          stageLabel: stageLabel,
          percent: percent,
          status: status,
          severity: severity,
          retryable: retryable,
          userMessage: userMessage,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
