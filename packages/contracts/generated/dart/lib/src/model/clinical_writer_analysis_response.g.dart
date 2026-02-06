// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_writer_analysis_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClinicalWriterAnalysisResponse extends ClinicalWriterAnalysisResponse {
  @override
  final BuiltList<ClinicalWriterSuggestion>? suggestions;
  @override
  final BuiltList<ClinicalWriterEntity>? entities;
  @override
  final BuiltList<ClinicalWriterAlert>? alerts;
  @override
  final BuiltList<ClinicalWriterHypothesis>? hypotheses;
  @override
  final BuiltList<ClinicalWriterKnowledgeItem>? knowledge;
  @override
  final String? phase;

  factory _$ClinicalWriterAnalysisResponse(
          [void Function(ClinicalWriterAnalysisResponseBuilder)? updates]) =>
      (ClinicalWriterAnalysisResponseBuilder()..update(updates))._build();

  _$ClinicalWriterAnalysisResponse._(
      {this.suggestions,
      this.entities,
      this.alerts,
      this.hypotheses,
      this.knowledge,
      this.phase})
      : super._();
  @override
  ClinicalWriterAnalysisResponse rebuild(
          void Function(ClinicalWriterAnalysisResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClinicalWriterAnalysisResponseBuilder toBuilder() =>
      ClinicalWriterAnalysisResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClinicalWriterAnalysisResponse &&
        suggestions == other.suggestions &&
        entities == other.entities &&
        alerts == other.alerts &&
        hypotheses == other.hypotheses &&
        knowledge == other.knowledge &&
        phase == other.phase;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, suggestions.hashCode);
    _$hash = $jc(_$hash, entities.hashCode);
    _$hash = $jc(_$hash, alerts.hashCode);
    _$hash = $jc(_$hash, hypotheses.hashCode);
    _$hash = $jc(_$hash, knowledge.hashCode);
    _$hash = $jc(_$hash, phase.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClinicalWriterAnalysisResponse')
          ..add('suggestions', suggestions)
          ..add('entities', entities)
          ..add('alerts', alerts)
          ..add('hypotheses', hypotheses)
          ..add('knowledge', knowledge)
          ..add('phase', phase))
        .toString();
  }
}

class ClinicalWriterAnalysisResponseBuilder
    implements
        Builder<ClinicalWriterAnalysisResponse,
            ClinicalWriterAnalysisResponseBuilder> {
  _$ClinicalWriterAnalysisResponse? _$v;

  ListBuilder<ClinicalWriterSuggestion>? _suggestions;
  ListBuilder<ClinicalWriterSuggestion> get suggestions =>
      _$this._suggestions ??= ListBuilder<ClinicalWriterSuggestion>();
  set suggestions(ListBuilder<ClinicalWriterSuggestion>? suggestions) =>
      _$this._suggestions = suggestions;

  ListBuilder<ClinicalWriterEntity>? _entities;
  ListBuilder<ClinicalWriterEntity> get entities =>
      _$this._entities ??= ListBuilder<ClinicalWriterEntity>();
  set entities(ListBuilder<ClinicalWriterEntity>? entities) =>
      _$this._entities = entities;

  ListBuilder<ClinicalWriterAlert>? _alerts;
  ListBuilder<ClinicalWriterAlert> get alerts =>
      _$this._alerts ??= ListBuilder<ClinicalWriterAlert>();
  set alerts(ListBuilder<ClinicalWriterAlert>? alerts) =>
      _$this._alerts = alerts;

  ListBuilder<ClinicalWriterHypothesis>? _hypotheses;
  ListBuilder<ClinicalWriterHypothesis> get hypotheses =>
      _$this._hypotheses ??= ListBuilder<ClinicalWriterHypothesis>();
  set hypotheses(ListBuilder<ClinicalWriterHypothesis>? hypotheses) =>
      _$this._hypotheses = hypotheses;

  ListBuilder<ClinicalWriterKnowledgeItem>? _knowledge;
  ListBuilder<ClinicalWriterKnowledgeItem> get knowledge =>
      _$this._knowledge ??= ListBuilder<ClinicalWriterKnowledgeItem>();
  set knowledge(ListBuilder<ClinicalWriterKnowledgeItem>? knowledge) =>
      _$this._knowledge = knowledge;

  String? _phase;
  String? get phase => _$this._phase;
  set phase(String? phase) => _$this._phase = phase;

  ClinicalWriterAnalysisResponseBuilder() {
    ClinicalWriterAnalysisResponse._defaults(this);
  }

  ClinicalWriterAnalysisResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _suggestions = $v.suggestions?.toBuilder();
      _entities = $v.entities?.toBuilder();
      _alerts = $v.alerts?.toBuilder();
      _hypotheses = $v.hypotheses?.toBuilder();
      _knowledge = $v.knowledge?.toBuilder();
      _phase = $v.phase;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClinicalWriterAnalysisResponse other) {
    _$v = other as _$ClinicalWriterAnalysisResponse;
  }

  @override
  void update(void Function(ClinicalWriterAnalysisResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClinicalWriterAnalysisResponse build() => _build();

  _$ClinicalWriterAnalysisResponse _build() {
    _$ClinicalWriterAnalysisResponse _$result;
    try {
      _$result = _$v ??
          _$ClinicalWriterAnalysisResponse._(
            suggestions: _suggestions?.build(),
            entities: _entities?.build(),
            alerts: _alerts?.build(),
            hypotheses: _hypotheses?.build(),
            knowledge: _knowledge?.build(),
            phase: phase,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'suggestions';
        _suggestions?.build();
        _$failedField = 'entities';
        _entities?.build();
        _$failedField = 'alerts';
        _alerts?.build();
        _$failedField = 'hypotheses';
        _hypotheses?.build();
        _$failedField = 'knowledge';
        _knowledge?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ClinicalWriterAnalysisResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
