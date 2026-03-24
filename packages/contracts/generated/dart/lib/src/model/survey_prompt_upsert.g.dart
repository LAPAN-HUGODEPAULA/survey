// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_prompt_upsert.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

abstract class SurveyPromptUpsertBuilder {
  void replace(SurveyPromptUpsert other);
  void update(void Function(SurveyPromptUpsertBuilder) updates);
  String? get promptKey;
  set promptKey(String? promptKey);

  String? get name;
  set name(String? name);

  SurveyPromptOutcomeType? get outcomeType;
  set outcomeType(SurveyPromptOutcomeType? outcomeType);

  String? get promptText;
  set promptText(String? promptText);
}

class _$$SurveyPromptUpsert extends $SurveyPromptUpsert {
  @override
  final String promptKey;
  @override
  final String name;
  @override
  final SurveyPromptOutcomeType outcomeType;
  @override
  final String promptText;

  factory _$$SurveyPromptUpsert(
          [void Function($SurveyPromptUpsertBuilder)? updates]) =>
      ($SurveyPromptUpsertBuilder()..update(updates))._build();

  _$$SurveyPromptUpsert._(
      {required this.promptKey,
      required this.name,
      required this.outcomeType,
      required this.promptText})
      : super._();
  @override
  $SurveyPromptUpsert rebuild(
          void Function($SurveyPromptUpsertBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $SurveyPromptUpsertBuilder toBuilder() =>
      $SurveyPromptUpsertBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $SurveyPromptUpsert &&
        promptKey == other.promptKey &&
        name == other.name &&
        outcomeType == other.outcomeType &&
        promptText == other.promptText;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, promptKey.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, outcomeType.hashCode);
    _$hash = $jc(_$hash, promptText.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'$SurveyPromptUpsert')
          ..add('promptKey', promptKey)
          ..add('name', name)
          ..add('outcomeType', outcomeType)
          ..add('promptText', promptText))
        .toString();
  }
}

class $SurveyPromptUpsertBuilder
    implements
        Builder<$SurveyPromptUpsert, $SurveyPromptUpsertBuilder>,
        SurveyPromptUpsertBuilder {
  _$$SurveyPromptUpsert? _$v;

  String? _promptKey;
  String? get promptKey => _$this._promptKey;
  set promptKey(covariant String? promptKey) => _$this._promptKey = promptKey;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  SurveyPromptOutcomeType? _outcomeType;
  SurveyPromptOutcomeType? get outcomeType => _$this._outcomeType;
  set outcomeType(covariant SurveyPromptOutcomeType? outcomeType) =>
      _$this._outcomeType = outcomeType;

  String? _promptText;
  String? get promptText => _$this._promptText;
  set promptText(covariant String? promptText) =>
      _$this._promptText = promptText;

  $SurveyPromptUpsertBuilder() {
    $SurveyPromptUpsert._defaults(this);
  }

  $SurveyPromptUpsertBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _promptKey = $v.promptKey;
      _name = $v.name;
      _outcomeType = $v.outcomeType;
      _promptText = $v.promptText;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant $SurveyPromptUpsert other) {
    _$v = other as _$$SurveyPromptUpsert;
  }

  @override
  void update(void Function($SurveyPromptUpsertBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $SurveyPromptUpsert build() => _build();

  _$$SurveyPromptUpsert _build() {
    final _$result = _$v ??
        _$$SurveyPromptUpsert._(
          promptKey: BuiltValueNullFieldError.checkNotNull(
              promptKey, r'$SurveyPromptUpsert', 'promptKey'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'$SurveyPromptUpsert', 'name'),
          outcomeType: BuiltValueNullFieldError.checkNotNull(
              outcomeType, r'$SurveyPromptUpsert', 'outcomeType'),
          promptText: BuiltValueNullFieldError.checkNotNull(
              promptText, r'$SurveyPromptUpsert', 'promptText'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
