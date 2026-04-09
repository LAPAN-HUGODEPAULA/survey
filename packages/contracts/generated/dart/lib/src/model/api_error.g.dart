// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ApiErrorSeverityEnum _$apiErrorSeverityEnum_info =
    const ApiErrorSeverityEnum._('info');
const ApiErrorSeverityEnum _$apiErrorSeverityEnum_warning =
    const ApiErrorSeverityEnum._('warning');
const ApiErrorSeverityEnum _$apiErrorSeverityEnum_error =
    const ApiErrorSeverityEnum._('error');
const ApiErrorSeverityEnum _$apiErrorSeverityEnum_critical =
    const ApiErrorSeverityEnum._('critical');

ApiErrorSeverityEnum _$apiErrorSeverityEnumValueOf(String name) {
  switch (name) {
    case 'info':
      return _$apiErrorSeverityEnum_info;
    case 'warning':
      return _$apiErrorSeverityEnum_warning;
    case 'error':
      return _$apiErrorSeverityEnum_error;
    case 'critical':
      return _$apiErrorSeverityEnum_critical;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ApiErrorSeverityEnum> _$apiErrorSeverityEnumValues =
    BuiltSet<ApiErrorSeverityEnum>(const <ApiErrorSeverityEnum>[
  _$apiErrorSeverityEnum_info,
  _$apiErrorSeverityEnum_warning,
  _$apiErrorSeverityEnum_error,
  _$apiErrorSeverityEnum_critical,
]);

Serializer<ApiErrorSeverityEnum> _$apiErrorSeverityEnumSerializer =
    _$ApiErrorSeverityEnumSerializer();

class _$ApiErrorSeverityEnumSerializer
    implements PrimitiveSerializer<ApiErrorSeverityEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'info': 'info',
    'warning': 'warning',
    'error': 'error',
    'critical': 'critical',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'info': 'info',
    'warning': 'warning',
    'error': 'error',
    'critical': 'critical',
  };

  @override
  final Iterable<Type> types = const <Type>[ApiErrorSeverityEnum];
  @override
  final String wireName = 'ApiErrorSeverityEnum';

  @override
  Object serialize(Serializers serializers, ApiErrorSeverityEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ApiErrorSeverityEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ApiErrorSeverityEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ApiError extends ApiError {
  @override
  final String code;
  @override
  final String userMessage;
  @override
  final ApiErrorSeverityEnum? severity;
  @override
  final bool? retryable;
  @override
  final String? requestId;
  @override
  final String? operation;
  @override
  final String? stage;
  @override
  final BuiltList<JsonObject>? details;

  factory _$ApiError([void Function(ApiErrorBuilder)? updates]) =>
      (ApiErrorBuilder()..update(updates))._build();

  _$ApiError._(
      {required this.code,
      required this.userMessage,
      this.severity,
      this.retryable,
      this.requestId,
      this.operation,
      this.stage,
      this.details})
      : super._();
  @override
  ApiError rebuild(void Function(ApiErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ApiErrorBuilder toBuilder() => ApiErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ApiError &&
        code == other.code &&
        userMessage == other.userMessage &&
        severity == other.severity &&
        retryable == other.retryable &&
        requestId == other.requestId &&
        operation == other.operation &&
        stage == other.stage &&
        details == other.details;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, userMessage.hashCode);
    _$hash = $jc(_$hash, severity.hashCode);
    _$hash = $jc(_$hash, retryable.hashCode);
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, operation.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ApiError')
          ..add('code', code)
          ..add('userMessage', userMessage)
          ..add('severity', severity)
          ..add('retryable', retryable)
          ..add('requestId', requestId)
          ..add('operation', operation)
          ..add('stage', stage)
          ..add('details', details))
        .toString();
  }
}

class ApiErrorBuilder implements Builder<ApiError, ApiErrorBuilder> {
  _$ApiError? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _userMessage;
  String? get userMessage => _$this._userMessage;
  set userMessage(String? userMessage) => _$this._userMessage = userMessage;

  ApiErrorSeverityEnum? _severity;
  ApiErrorSeverityEnum? get severity => _$this._severity;
  set severity(ApiErrorSeverityEnum? severity) => _$this._severity = severity;

  bool? _retryable;
  bool? get retryable => _$this._retryable;
  set retryable(bool? retryable) => _$this._retryable = retryable;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  String? _operation;
  String? get operation => _$this._operation;
  set operation(String? operation) => _$this._operation = operation;

  String? _stage;
  String? get stage => _$this._stage;
  set stage(String? stage) => _$this._stage = stage;

  ListBuilder<JsonObject>? _details;
  ListBuilder<JsonObject> get details =>
      _$this._details ??= ListBuilder<JsonObject>();
  set details(ListBuilder<JsonObject>? details) => _$this._details = details;

  ApiErrorBuilder() {
    ApiError._defaults(this);
  }

  ApiErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _userMessage = $v.userMessage;
      _severity = $v.severity;
      _retryable = $v.retryable;
      _requestId = $v.requestId;
      _operation = $v.operation;
      _stage = $v.stage;
      _details = $v.details?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ApiError other) {
    _$v = other as _$ApiError;
  }

  @override
  void update(void Function(ApiErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ApiError build() => _build();

  _$ApiError _build() {
    _$ApiError _$result;
    try {
      _$result = _$v ??
          _$ApiError._(
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'ApiError', 'code'),
            userMessage: BuiltValueNullFieldError.checkNotNull(
                userMessage, r'ApiError', 'userMessage'),
            severity: severity,
            retryable: retryable,
            requestId: requestId,
            operation: operation,
            stage: stage,
            details: _details?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'details';
        _details?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ApiError', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
