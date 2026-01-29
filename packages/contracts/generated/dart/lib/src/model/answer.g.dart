// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Answer extends Answer {
  @override
  final int? id;
  @override
  final String? answer;

  factory _$Answer([void Function(AnswerBuilder)? updates]) =>
      (AnswerBuilder()..update(updates))._build();

  _$Answer._({this.id, this.answer}) : super._();
  @override
  Answer rebuild(void Function(AnswerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AnswerBuilder toBuilder() => AnswerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Answer && id == other.id && answer == other.answer;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, answer.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Answer')
          ..add('id', id)
          ..add('answer', answer))
        .toString();
  }
}

class AnswerBuilder implements Builder<Answer, AnswerBuilder> {
  _$Answer? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _answer;
  String? get answer => _$this._answer;
  set answer(String? answer) => _$this._answer = answer;

  AnswerBuilder() {
    Answer._defaults(this);
  }

  AnswerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _answer = $v.answer;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Answer other) {
    _$v = other as _$Answer;
  }

  @override
  void update(void Function(AnswerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Answer build() => _build();

  _$Answer _build() {
    final _$result = _$v ??
        _$Answer._(
          id: id,
          answer: answer,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
