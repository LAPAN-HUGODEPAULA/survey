// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screener_settings_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ScreenerSettingsUpdate extends ScreenerSettingsUpdate {
  @override
  final String defaultQuestionnaireId;

  factory _$ScreenerSettingsUpdate(
          [void Function(ScreenerSettingsUpdateBuilder)? updates]) =>
      (ScreenerSettingsUpdateBuilder()..update(updates))._build();

  _$ScreenerSettingsUpdate._({required this.defaultQuestionnaireId})
      : super._();
  @override
  ScreenerSettingsUpdate rebuild(
          void Function(ScreenerSettingsUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScreenerSettingsUpdateBuilder toBuilder() =>
      ScreenerSettingsUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScreenerSettingsUpdate &&
        defaultQuestionnaireId == other.defaultQuestionnaireId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, defaultQuestionnaireId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ScreenerSettingsUpdate')
          ..add('defaultQuestionnaireId', defaultQuestionnaireId))
        .toString();
  }
}

class ScreenerSettingsUpdateBuilder
    implements Builder<ScreenerSettingsUpdate, ScreenerSettingsUpdateBuilder> {
  _$ScreenerSettingsUpdate? _$v;

  String? _defaultQuestionnaireId;
  String? get defaultQuestionnaireId => _$this._defaultQuestionnaireId;
  set defaultQuestionnaireId(String? defaultQuestionnaireId) =>
      _$this._defaultQuestionnaireId = defaultQuestionnaireId;

  ScreenerSettingsUpdateBuilder() {
    ScreenerSettingsUpdate._defaults(this);
  }

  ScreenerSettingsUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _defaultQuestionnaireId = $v.defaultQuestionnaireId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScreenerSettingsUpdate other) {
    _$v = other as _$ScreenerSettingsUpdate;
  }

  @override
  void update(void Function(ScreenerSettingsUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScreenerSettingsUpdate build() => _build();

  _$ScreenerSettingsUpdate _build() {
    final _$result = _$v ??
        _$ScreenerSettingsUpdate._(
          defaultQuestionnaireId: BuiltValueNullFieldError.checkNotNull(
              defaultQuestionnaireId,
              r'ScreenerSettingsUpdate',
              'defaultQuestionnaireId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
