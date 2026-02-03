// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Question extends Question {
  @override
  final int id;
  @override
  final String questionText;
  @override
  final BuiltList<String> answers;

  factory _$Question([void Function(QuestionBuilder)? updates]) =>
      (QuestionBuilder()..update(updates))._build();

  _$Question._(
      {required this.id, required this.questionText, required this.answers})
      : super._();
  @override
  Question rebuild(void Function(QuestionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  QuestionBuilder toBuilder() => QuestionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Question &&
        id == other.id &&
        questionText == other.questionText &&
        answers == other.answers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, questionText.hashCode);
    _$hash = $jc(_$hash, answers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Question')
          ..add('id', id)
          ..add('questionText', questionText)
          ..add('answers', answers))
        .toString();
  }
}

class QuestionBuilder implements Builder<Question, QuestionBuilder> {
  _$Question? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _questionText;
  String? get questionText => _$this._questionText;
  set questionText(String? questionText) => _$this._questionText = questionText;

  ListBuilder<String>? _answers;
  ListBuilder<String> get answers => _$this._answers ??= ListBuilder<String>();
  set answers(ListBuilder<String>? answers) => _$this._answers = answers;

  QuestionBuilder() {
    Question._defaults(this);
  }

  QuestionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _questionText = $v.questionText;
      _answers = $v.answers.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Question other) {
    _$v = other as _$Question;
  }

  @override
  void update(void Function(QuestionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Question build() => _build();

  _$Question _build() {
    _$Question _$result;
    try {
      _$result = _$v ??
          _$Question._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Question', 'id'),
            questionText: BuiltValueNullFieldError.checkNotNull(
                questionText, r'Question', 'questionText'),
            answers: answers.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'answers';
        answers.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Question', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
