// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screener_password_recovery_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ScreenerPasswordRecoveryRequest
    extends ScreenerPasswordRecoveryRequest {
  @override
  final String email;

  factory _$ScreenerPasswordRecoveryRequest(
          [void Function(ScreenerPasswordRecoveryRequestBuilder)? updates]) =>
      (ScreenerPasswordRecoveryRequestBuilder()..update(updates))._build();

  _$ScreenerPasswordRecoveryRequest._({required this.email}) : super._();
  @override
  ScreenerPasswordRecoveryRequest rebuild(
          void Function(ScreenerPasswordRecoveryRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScreenerPasswordRecoveryRequestBuilder toBuilder() =>
      ScreenerPasswordRecoveryRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScreenerPasswordRecoveryRequest && email == other.email;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ScreenerPasswordRecoveryRequest')
          ..add('email', email))
        .toString();
  }
}

class ScreenerPasswordRecoveryRequestBuilder
    implements
        Builder<ScreenerPasswordRecoveryRequest,
            ScreenerPasswordRecoveryRequestBuilder> {
  _$ScreenerPasswordRecoveryRequest? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  ScreenerPasswordRecoveryRequestBuilder() {
    ScreenerPasswordRecoveryRequest._defaults(this);
  }

  ScreenerPasswordRecoveryRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScreenerPasswordRecoveryRequest other) {
    _$v = other as _$ScreenerPasswordRecoveryRequest;
  }

  @override
  void update(void Function(ScreenerPasswordRecoveryRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScreenerPasswordRecoveryRequest build() => _build();

  _$ScreenerPasswordRecoveryRequest _build() {
    final _$result = _$v ??
        _$ScreenerPasswordRecoveryRequest._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'ScreenerPasswordRecoveryRequest', 'email'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
