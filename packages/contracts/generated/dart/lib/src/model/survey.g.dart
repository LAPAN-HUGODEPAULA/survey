// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Survey extends Survey {
  @override
  final String? id;
  @override
  final String surveyDisplayName;
  @override
  final String surveyName;
  @override
  final String surveyDescription;
  @override
  final String creatorId;
  @override
  final DateTime createdAt;
  @override
  final DateTime modifiedAt;
  @override
  final Instructions instructions;
  @override
  final BuiltList<Question> questions;
  @override
  final String finalNotes;

  factory _$Survey([void Function(SurveyBuilder)? updates]) =>
      (SurveyBuilder()..update(updates))._build();

  _$Survey._(
      {this.id,
      required this.surveyDisplayName,
      required this.surveyName,
      required this.surveyDescription,
      required this.creatorId,
      required this.createdAt,
      required this.modifiedAt,
      required this.instructions,
      required this.questions,
      required this.finalNotes})
      : super._();
  @override
  Survey rebuild(void Function(SurveyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SurveyBuilder toBuilder() => SurveyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Survey &&
        id == other.id &&
        surveyDisplayName == other.surveyDisplayName &&
        surveyName == other.surveyName &&
        surveyDescription == other.surveyDescription &&
        creatorId == other.creatorId &&
        createdAt == other.createdAt &&
        modifiedAt == other.modifiedAt &&
        instructions == other.instructions &&
        questions == other.questions &&
        finalNotes == other.finalNotes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, surveyDisplayName.hashCode);
    _$hash = $jc(_$hash, surveyName.hashCode);
    _$hash = $jc(_$hash, surveyDescription.hashCode);
    _$hash = $jc(_$hash, creatorId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, modifiedAt.hashCode);
    _$hash = $jc(_$hash, instructions.hashCode);
    _$hash = $jc(_$hash, questions.hashCode);
    _$hash = $jc(_$hash, finalNotes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Survey')
          ..add('id', id)
          ..add('surveyDisplayName', surveyDisplayName)
          ..add('surveyName', surveyName)
          ..add('surveyDescription', surveyDescription)
          ..add('creatorId', creatorId)
          ..add('createdAt', createdAt)
          ..add('modifiedAt', modifiedAt)
          ..add('instructions', instructions)
          ..add('questions', questions)
          ..add('finalNotes', finalNotes))
        .toString();
  }
}

class SurveyBuilder implements Builder<Survey, SurveyBuilder> {
  _$Survey? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _surveyDisplayName;
  String? get surveyDisplayName => _$this._surveyDisplayName;
  set surveyDisplayName(String? surveyDisplayName) =>
      _$this._surveyDisplayName = surveyDisplayName;

  String? _surveyName;
  String? get surveyName => _$this._surveyName;
  set surveyName(String? surveyName) => _$this._surveyName = surveyName;

  String? _surveyDescription;
  String? get surveyDescription => _$this._surveyDescription;
  set surveyDescription(String? surveyDescription) =>
      _$this._surveyDescription = surveyDescription;

  String? _creatorId;
  String? get creatorId => _$this._creatorId;
  set creatorId(String? creatorId) => _$this._creatorId = creatorId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _modifiedAt;
  DateTime? get modifiedAt => _$this._modifiedAt;
  set modifiedAt(DateTime? modifiedAt) => _$this._modifiedAt = modifiedAt;

  InstructionsBuilder? _instructions;
  InstructionsBuilder get instructions =>
      _$this._instructions ??= InstructionsBuilder();
  set instructions(InstructionsBuilder? instructions) =>
      _$this._instructions = instructions;

  ListBuilder<Question>? _questions;
  ListBuilder<Question> get questions =>
      _$this._questions ??= ListBuilder<Question>();
  set questions(ListBuilder<Question>? questions) =>
      _$this._questions = questions;

  String? _finalNotes;
  String? get finalNotes => _$this._finalNotes;
  set finalNotes(String? finalNotes) => _$this._finalNotes = finalNotes;

  SurveyBuilder() {
    Survey._defaults(this);
  }

  SurveyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _surveyDisplayName = $v.surveyDisplayName;
      _surveyName = $v.surveyName;
      _surveyDescription = $v.surveyDescription;
      _creatorId = $v.creatorId;
      _createdAt = $v.createdAt;
      _modifiedAt = $v.modifiedAt;
      _instructions = $v.instructions.toBuilder();
      _questions = $v.questions.toBuilder();
      _finalNotes = $v.finalNotes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Survey other) {
    _$v = other as _$Survey;
  }

  @override
  void update(void Function(SurveyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Survey build() => _build();

  _$Survey _build() {
    _$Survey _$result;
    try {
      _$result = _$v ??
          _$Survey._(
            id: id,
            surveyDisplayName: BuiltValueNullFieldError.checkNotNull(
                surveyDisplayName, r'Survey', 'surveyDisplayName'),
            surveyName: BuiltValueNullFieldError.checkNotNull(
                surveyName, r'Survey', 'surveyName'),
            surveyDescription: BuiltValueNullFieldError.checkNotNull(
                surveyDescription, r'Survey', 'surveyDescription'),
            creatorId: BuiltValueNullFieldError.checkNotNull(
                creatorId, r'Survey', 'creatorId'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Survey', 'createdAt'),
            modifiedAt: BuiltValueNullFieldError.checkNotNull(
                modifiedAt, r'Survey', 'modifiedAt'),
            instructions: instructions.build(),
            questions: questions.build(),
            finalNotes: BuiltValueNullFieldError.checkNotNull(
                finalNotes, r'Survey', 'finalNotes'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'instructions';
        instructions.build();
        _$failedField = 'questions';
        questions.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Survey', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
