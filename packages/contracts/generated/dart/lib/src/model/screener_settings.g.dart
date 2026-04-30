// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screener_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ScreenerSettings extends ScreenerSettings {
  @override
  final String? defaultQuestionnaireId;
  @override
  final String? defaultQuestionnaireName;

  factory _$ScreenerSettings(
          [void Function(ScreenerSettingsBuilder)? updates]) =>
      (ScreenerSettingsBuilder()..update(updates))._build();

  _$ScreenerSettings._(
      {this.defaultQuestionnaireId, this.defaultQuestionnaireName})
      : super._();
  @override
  ScreenerSettings rebuild(void Function(ScreenerSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScreenerSettingsBuilder toBuilder() =>
      ScreenerSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScreenerSettings &&
        defaultQuestionnaireId == other.defaultQuestionnaireId &&
        defaultQuestionnaireName == other.defaultQuestionnaireName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, defaultQuestionnaireId.hashCode);
    _$hash = $jc(_$hash, defaultQuestionnaireName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ScreenerSettings')
          ..add('defaultQuestionnaireId', defaultQuestionnaireId)
          ..add('defaultQuestionnaireName', defaultQuestionnaireName))
        .toString();
  }
}

class ScreenerSettingsBuilder
    implements Builder<ScreenerSettings, ScreenerSettingsBuilder> {
  _$ScreenerSettings? _$v;

  String? _defaultQuestionnaireId;
  String? get defaultQuestionnaireId => _$this._defaultQuestionnaireId;
  set defaultQuestionnaireId(String? defaultQuestionnaireId) =>
      _$this._defaultQuestionnaireId = defaultQuestionnaireId;

  String? _defaultQuestionnaireName;
  String? get defaultQuestionnaireName => _$this._defaultQuestionnaireName;
  set defaultQuestionnaireName(String? defaultQuestionnaireName) =>
      _$this._defaultQuestionnaireName = defaultQuestionnaireName;

  ScreenerSettingsBuilder() {
    ScreenerSettings._defaults(this);
  }

  ScreenerSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _defaultQuestionnaireId = $v.defaultQuestionnaireId;
      _defaultQuestionnaireName = $v.defaultQuestionnaireName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScreenerSettings other) {
    _$v = other as _$ScreenerSettings;
  }

  @override
  void update(void Function(ScreenerSettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScreenerSettings build() => _build();

  _$ScreenerSettings _build() {
    final _$result = _$v ??
        _$ScreenerSettings._(
          defaultQuestionnaireId: defaultQuestionnaireId,
          defaultQuestionnaireName: defaultQuestionnaireName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
