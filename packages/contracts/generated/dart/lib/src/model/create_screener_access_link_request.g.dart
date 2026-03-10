// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_screener_access_link_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateScreenerAccessLinkRequest
    extends CreateScreenerAccessLinkRequest {
  @override
  final String surveyId;

  factory _$CreateScreenerAccessLinkRequest(
          [void Function(CreateScreenerAccessLinkRequestBuilder)? updates]) =>
      (CreateScreenerAccessLinkRequestBuilder()..update(updates))._build();

  _$CreateScreenerAccessLinkRequest._({required this.surveyId}) : super._();
  @override
  CreateScreenerAccessLinkRequest rebuild(
          void Function(CreateScreenerAccessLinkRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateScreenerAccessLinkRequestBuilder toBuilder() =>
      CreateScreenerAccessLinkRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateScreenerAccessLinkRequest &&
        surveyId == other.surveyId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, surveyId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateScreenerAccessLinkRequest')
          ..add('surveyId', surveyId))
        .toString();
  }
}

class CreateScreenerAccessLinkRequestBuilder
    implements
        Builder<CreateScreenerAccessLinkRequest,
            CreateScreenerAccessLinkRequestBuilder> {
  _$CreateScreenerAccessLinkRequest? _$v;

  String? _surveyId;
  String? get surveyId => _$this._surveyId;
  set surveyId(String? surveyId) => _$this._surveyId = surveyId;

  CreateScreenerAccessLinkRequestBuilder() {
    CreateScreenerAccessLinkRequest._defaults(this);
  }

  CreateScreenerAccessLinkRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _surveyId = $v.surveyId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateScreenerAccessLinkRequest other) {
    _$v = other as _$CreateScreenerAccessLinkRequest;
  }

  @override
  void update(void Function(CreateScreenerAccessLinkRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateScreenerAccessLinkRequest build() => _build();

  _$CreateScreenerAccessLinkRequest _build() {
    final _$result = _$v ??
        _$CreateScreenerAccessLinkRequest._(
          surveyId: BuiltValueNullFieldError.checkNotNull(
              surveyId, r'CreateScreenerAccessLinkRequest', 'surveyId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
