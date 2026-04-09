// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'process_clinical_writer200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProcessClinicalWriter200Response
    extends ProcessClinicalWriter200Response {
  @override
  final OneOf oneOf;

  factory _$ProcessClinicalWriter200Response(
          [void Function(ProcessClinicalWriter200ResponseBuilder)? updates]) =>
      (ProcessClinicalWriter200ResponseBuilder()..update(updates))._build();

  _$ProcessClinicalWriter200Response._({required this.oneOf}) : super._();
  @override
  ProcessClinicalWriter200Response rebuild(
          void Function(ProcessClinicalWriter200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProcessClinicalWriter200ResponseBuilder toBuilder() =>
      ProcessClinicalWriter200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProcessClinicalWriter200Response && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProcessClinicalWriter200Response')
          ..add('oneOf', oneOf))
        .toString();
  }
}

class ProcessClinicalWriter200ResponseBuilder
    implements
        Builder<ProcessClinicalWriter200Response,
            ProcessClinicalWriter200ResponseBuilder> {
  _$ProcessClinicalWriter200Response? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  ProcessClinicalWriter200ResponseBuilder() {
    ProcessClinicalWriter200Response._defaults(this);
  }

  ProcessClinicalWriter200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProcessClinicalWriter200Response other) {
    _$v = other as _$ProcessClinicalWriter200Response;
  }

  @override
  void update(void Function(ProcessClinicalWriter200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProcessClinicalWriter200Response build() => _build();

  _$ProcessClinicalWriter200Response _build() {
    final _$result = _$v ??
        _$ProcessClinicalWriter200Response._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'ProcessClinicalWriter200Response', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
