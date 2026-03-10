// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screener_access_link.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ScreenerAccessLink extends ScreenerAccessLink {
  @override
  final String token;
  @override
  final String screenerId;
  @override
  final String screenerName;
  @override
  final String surveyId;
  @override
  final String surveyDisplayName;
  @override
  final DateTime createdAt;

  factory _$ScreenerAccessLink(
          [void Function(ScreenerAccessLinkBuilder)? updates]) =>
      (ScreenerAccessLinkBuilder()..update(updates))._build();

  _$ScreenerAccessLink._(
      {required this.token,
      required this.screenerId,
      required this.screenerName,
      required this.surveyId,
      required this.surveyDisplayName,
      required this.createdAt})
      : super._();
  @override
  ScreenerAccessLink rebuild(
          void Function(ScreenerAccessLinkBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScreenerAccessLinkBuilder toBuilder() =>
      ScreenerAccessLinkBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScreenerAccessLink &&
        token == other.token &&
        screenerId == other.screenerId &&
        screenerName == other.screenerName &&
        surveyId == other.surveyId &&
        surveyDisplayName == other.surveyDisplayName &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, screenerId.hashCode);
    _$hash = $jc(_$hash, screenerName.hashCode);
    _$hash = $jc(_$hash, surveyId.hashCode);
    _$hash = $jc(_$hash, surveyDisplayName.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ScreenerAccessLink')
          ..add('token', token)
          ..add('screenerId', screenerId)
          ..add('screenerName', screenerName)
          ..add('surveyId', surveyId)
          ..add('surveyDisplayName', surveyDisplayName)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class ScreenerAccessLinkBuilder
    implements Builder<ScreenerAccessLink, ScreenerAccessLinkBuilder> {
  _$ScreenerAccessLink? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  String? _screenerId;
  String? get screenerId => _$this._screenerId;
  set screenerId(String? screenerId) => _$this._screenerId = screenerId;

  String? _screenerName;
  String? get screenerName => _$this._screenerName;
  set screenerName(String? screenerName) => _$this._screenerName = screenerName;

  String? _surveyId;
  String? get surveyId => _$this._surveyId;
  set surveyId(String? surveyId) => _$this._surveyId = surveyId;

  String? _surveyDisplayName;
  String? get surveyDisplayName => _$this._surveyDisplayName;
  set surveyDisplayName(String? surveyDisplayName) =>
      _$this._surveyDisplayName = surveyDisplayName;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  ScreenerAccessLinkBuilder() {
    ScreenerAccessLink._defaults(this);
  }

  ScreenerAccessLinkBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _screenerId = $v.screenerId;
      _screenerName = $v.screenerName;
      _surveyId = $v.surveyId;
      _surveyDisplayName = $v.surveyDisplayName;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScreenerAccessLink other) {
    _$v = other as _$ScreenerAccessLink;
  }

  @override
  void update(void Function(ScreenerAccessLinkBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScreenerAccessLink build() => _build();

  _$ScreenerAccessLink _build() {
    final _$result = _$v ??
        _$ScreenerAccessLink._(
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'ScreenerAccessLink', 'token'),
          screenerId: BuiltValueNullFieldError.checkNotNull(
              screenerId, r'ScreenerAccessLink', 'screenerId'),
          screenerName: BuiltValueNullFieldError.checkNotNull(
              screenerName, r'ScreenerAccessLink', 'screenerName'),
          surveyId: BuiltValueNullFieldError.checkNotNull(
              surveyId, r'ScreenerAccessLink', 'surveyId'),
          surveyDisplayName: BuiltValueNullFieldError.checkNotNull(
              surveyDisplayName, r'ScreenerAccessLink', 'surveyDisplayName'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ScreenerAccessLink', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
