// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_prompt_association.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SurveyPromptAssociation extends SurveyPromptAssociation {
  @override
  final String promptKey;
  @override
  final String name;
  @override
  final SurveyPromptOutcomeType outcomeType;

  factory _$SurveyPromptAssociation(
          [void Function(SurveyPromptAssociationBuilder)? updates]) =>
      (SurveyPromptAssociationBuilder()..update(updates))._build();

  _$SurveyPromptAssociation._(
      {required this.promptKey, required this.name, required this.outcomeType})
      : super._();
  @override
  SurveyPromptAssociation rebuild(
          void Function(SurveyPromptAssociationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SurveyPromptAssociationBuilder toBuilder() =>
      SurveyPromptAssociationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SurveyPromptAssociation &&
        promptKey == other.promptKey &&
        name == other.name &&
        outcomeType == other.outcomeType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, promptKey.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, outcomeType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SurveyPromptAssociation')
          ..add('promptKey', promptKey)
          ..add('name', name)
          ..add('outcomeType', outcomeType))
        .toString();
  }
}

class SurveyPromptAssociationBuilder
    implements
        Builder<SurveyPromptAssociation, SurveyPromptAssociationBuilder> {
  _$SurveyPromptAssociation? _$v;

  String? _promptKey;
  String? get promptKey => _$this._promptKey;
  set promptKey(String? promptKey) => _$this._promptKey = promptKey;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  SurveyPromptOutcomeType? _outcomeType;
  SurveyPromptOutcomeType? get outcomeType => _$this._outcomeType;
  set outcomeType(SurveyPromptOutcomeType? outcomeType) =>
      _$this._outcomeType = outcomeType;

  SurveyPromptAssociationBuilder() {
    SurveyPromptAssociation._defaults(this);
  }

  SurveyPromptAssociationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _promptKey = $v.promptKey;
      _name = $v.name;
      _outcomeType = $v.outcomeType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SurveyPromptAssociation other) {
    _$v = other as _$SurveyPromptAssociation;
  }

  @override
  void update(void Function(SurveyPromptAssociationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SurveyPromptAssociation build() => _build();

  _$SurveyPromptAssociation _build() {
    final _$result = _$v ??
        _$SurveyPromptAssociation._(
          promptKey: BuiltValueNullFieldError.checkNotNull(
              promptKey, r'SurveyPromptAssociation', 'promptKey'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'SurveyPromptAssociation', 'name'),
          outcomeType: BuiltValueNullFieldError.checkNotNull(
              outcomeType, r'SurveyPromptAssociation', 'outcomeType'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
