// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instructions.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Instructions extends Instructions {
  @override
  final String preamble;
  @override
  final String questionText;
  @override
  final BuiltList<String> answers;

  factory _$Instructions([void Function(InstructionsBuilder)? updates]) =>
      (InstructionsBuilder()..update(updates))._build();

  _$Instructions._(
      {required this.preamble,
      required this.questionText,
      required this.answers})
      : super._();
  @override
  Instructions rebuild(void Function(InstructionsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InstructionsBuilder toBuilder() => InstructionsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Instructions &&
        preamble == other.preamble &&
        questionText == other.questionText &&
        answers == other.answers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, preamble.hashCode);
    _$hash = $jc(_$hash, questionText.hashCode);
    _$hash = $jc(_$hash, answers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Instructions')
          ..add('preamble', preamble)
          ..add('questionText', questionText)
          ..add('answers', answers))
        .toString();
  }
}

class InstructionsBuilder
    implements Builder<Instructions, InstructionsBuilder> {
  _$Instructions? _$v;

  String? _preamble;
  String? get preamble => _$this._preamble;
  set preamble(String? preamble) => _$this._preamble = preamble;

  String? _questionText;
  String? get questionText => _$this._questionText;
  set questionText(String? questionText) => _$this._questionText = questionText;

  ListBuilder<String>? _answers;
  ListBuilder<String> get answers => _$this._answers ??= ListBuilder<String>();
  set answers(ListBuilder<String>? answers) => _$this._answers = answers;

  InstructionsBuilder() {
    Instructions._defaults(this);
  }

  InstructionsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _preamble = $v.preamble;
      _questionText = $v.questionText;
      _answers = $v.answers.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Instructions other) {
    _$v = other as _$Instructions;
  }

  @override
  void update(void Function(InstructionsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Instructions build() => _build();

  _$Instructions _build() {
    _$Instructions _$result;
    try {
      _$result = _$v ??
          _$Instructions._(
            preamble: BuiltValueNullFieldError.checkNotNull(
                preamble, r'Instructions', 'preamble'),
            questionText: BuiltValueNullFieldError.checkNotNull(
                questionText, r'Instructions', 'questionText'),
            answers: answers.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'answers';
        answers.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Instructions', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
