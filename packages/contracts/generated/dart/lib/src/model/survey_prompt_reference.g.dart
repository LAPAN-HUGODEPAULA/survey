// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_prompt_reference.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SurveyPromptReference extends SurveyPromptReference {
  @override
  final String promptKey;
  @override
  final String name;

  factory _$SurveyPromptReference(
          [void Function(SurveyPromptReferenceBuilder)? updates]) =>
      (SurveyPromptReferenceBuilder()..update(updates))._build();

  _$SurveyPromptReference._({required this.promptKey, required this.name})
      : super._();
  @override
  SurveyPromptReference rebuild(
          void Function(SurveyPromptReferenceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SurveyPromptReferenceBuilder toBuilder() =>
      SurveyPromptReferenceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SurveyPromptReference &&
        promptKey == other.promptKey &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, promptKey.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SurveyPromptReference')
          ..add('promptKey', promptKey)
          ..add('name', name))
        .toString();
  }
}

class SurveyPromptReferenceBuilder
    implements Builder<SurveyPromptReference, SurveyPromptReferenceBuilder> {
  _$SurveyPromptReference? _$v;

  String? _promptKey;
  String? get promptKey => _$this._promptKey;
  set promptKey(String? promptKey) => _$this._promptKey = promptKey;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  SurveyPromptReferenceBuilder() {
    SurveyPromptReference._defaults(this);
  }

  SurveyPromptReferenceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _promptKey = $v.promptKey;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SurveyPromptReference other) {
    _$v = other as _$SurveyPromptReference;
  }

  @override
  void update(void Function(SurveyPromptReferenceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SurveyPromptReference build() => _build();

  _$SurveyPromptReference _build() {
    final _$result = _$v ??
        _$SurveyPromptReference._(
          promptKey: BuiltValueNullFieldError.checkNotNull(
              promptKey, r'SurveyPromptReference', 'promptKey'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'SurveyPromptReference', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
