// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_prompt.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SurveyPrompt extends SurveyPrompt {
  @override
  final DateTime createdAt;
  @override
  final DateTime modifiedAt;
  @override
  final String promptKey;
  @override
  final String name;
  @override
  final String promptText;

  factory _$SurveyPrompt([void Function(SurveyPromptBuilder)? updates]) =>
      (SurveyPromptBuilder()..update(updates))._build();

  _$SurveyPrompt._(
      {required this.createdAt,
      required this.modifiedAt,
      required this.promptKey,
      required this.name,
      required this.promptText})
      : super._();
  @override
  SurveyPrompt rebuild(void Function(SurveyPromptBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SurveyPromptBuilder toBuilder() => SurveyPromptBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SurveyPrompt &&
        createdAt == other.createdAt &&
        modifiedAt == other.modifiedAt &&
        promptKey == other.promptKey &&
        name == other.name &&
        promptText == other.promptText;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, modifiedAt.hashCode);
    _$hash = $jc(_$hash, promptKey.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, promptText.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SurveyPrompt')
          ..add('createdAt', createdAt)
          ..add('modifiedAt', modifiedAt)
          ..add('promptKey', promptKey)
          ..add('name', name)
          ..add('promptText', promptText))
        .toString();
  }
}

class SurveyPromptBuilder
    implements
        Builder<SurveyPrompt, SurveyPromptBuilder>,
        SurveyPromptUpsertBuilder {
  _$SurveyPrompt? _$v;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(covariant DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _modifiedAt;
  DateTime? get modifiedAt => _$this._modifiedAt;
  set modifiedAt(covariant DateTime? modifiedAt) =>
      _$this._modifiedAt = modifiedAt;

  String? _promptKey;
  String? get promptKey => _$this._promptKey;
  set promptKey(covariant String? promptKey) => _$this._promptKey = promptKey;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  String? _promptText;
  String? get promptText => _$this._promptText;
  set promptText(covariant String? promptText) =>
      _$this._promptText = promptText;

  SurveyPromptBuilder() {
    SurveyPrompt._defaults(this);
  }

  SurveyPromptBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _createdAt = $v.createdAt;
      _modifiedAt = $v.modifiedAt;
      _promptKey = $v.promptKey;
      _name = $v.name;
      _promptText = $v.promptText;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant SurveyPrompt other) {
    _$v = other as _$SurveyPrompt;
  }

  @override
  void update(void Function(SurveyPromptBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SurveyPrompt build() => _build();

  _$SurveyPrompt _build() {
    final _$result = _$v ??
        _$SurveyPrompt._(
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'SurveyPrompt', 'createdAt'),
          modifiedAt: BuiltValueNullFieldError.checkNotNull(
              modifiedAt, r'SurveyPrompt', 'modifiedAt'),
          promptKey: BuiltValueNullFieldError.checkNotNull(
              promptKey, r'SurveyPrompt', 'promptKey'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'SurveyPrompt', 'name'),
          promptText: BuiltValueNullFieldError.checkNotNull(
              promptText, r'SurveyPrompt', 'promptText'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
