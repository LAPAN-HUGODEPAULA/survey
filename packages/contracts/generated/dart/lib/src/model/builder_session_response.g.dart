// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'builder_session_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BuilderSessionResponse extends BuilderSessionResponse {
  @override
  final ScreenerProfile profile;
  @override
  final String csrfToken;

  factory _$BuilderSessionResponse(
          [void Function(BuilderSessionResponseBuilder)? updates]) =>
      (BuilderSessionResponseBuilder()..update(updates))._build();

  _$BuilderSessionResponse._({required this.profile, required this.csrfToken})
      : super._();
  @override
  BuilderSessionResponse rebuild(
          void Function(BuilderSessionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BuilderSessionResponseBuilder toBuilder() =>
      BuilderSessionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BuilderSessionResponse &&
        profile == other.profile &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, profile.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BuilderSessionResponse')
          ..add('profile', profile)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class BuilderSessionResponseBuilder
    implements Builder<BuilderSessionResponse, BuilderSessionResponseBuilder> {
  _$BuilderSessionResponse? _$v;

  ScreenerProfileBuilder? _profile;
  ScreenerProfileBuilder get profile =>
      _$this._profile ??= ScreenerProfileBuilder();
  set profile(ScreenerProfileBuilder? profile) => _$this._profile = profile;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(String? csrfToken) => _$this._csrfToken = csrfToken;

  BuilderSessionResponseBuilder() {
    BuilderSessionResponse._defaults(this);
  }

  BuilderSessionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _profile = $v.profile.toBuilder();
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BuilderSessionResponse other) {
    _$v = other as _$BuilderSessionResponse;
  }

  @override
  void update(void Function(BuilderSessionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BuilderSessionResponse build() => _build();

  _$BuilderSessionResponse _build() {
    _$BuilderSessionResponse _$result;
    try {
      _$result = _$v ??
          _$BuilderSessionResponse._(
            profile: profile.build(),
            csrfToken: BuiltValueNullFieldError.checkNotNull(
                csrfToken, r'BuilderSessionResponse', 'csrfToken'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'profile';
        profile.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BuilderSessionResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
