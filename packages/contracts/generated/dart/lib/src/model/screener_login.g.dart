// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screener_login.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ScreenerLogin extends ScreenerLogin {
  @override
  final String email;
  @override
  final String password;

  factory _$ScreenerLogin([void Function(ScreenerLoginBuilder)? updates]) =>
      (ScreenerLoginBuilder()..update(updates))._build();

  _$ScreenerLogin._({required this.email, required this.password}) : super._();
  @override
  ScreenerLogin rebuild(void Function(ScreenerLoginBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScreenerLoginBuilder toBuilder() => ScreenerLoginBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScreenerLogin &&
        email == other.email &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ScreenerLogin')
          ..add('email', email)
          ..add('password', password))
        .toString();
  }
}

class ScreenerLoginBuilder
    implements Builder<ScreenerLogin, ScreenerLoginBuilder> {
  _$ScreenerLogin? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  ScreenerLoginBuilder() {
    ScreenerLogin._defaults(this);
  }

  ScreenerLoginBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScreenerLogin other) {
    _$v = other as _$ScreenerLogin;
  }

  @override
  void update(void Function(ScreenerLoginBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScreenerLogin build() => _build();

  _$ScreenerLogin _build() {
    final _$result = _$v ??
        _$ScreenerLogin._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'ScreenerLogin', 'email'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'ScreenerLogin', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
