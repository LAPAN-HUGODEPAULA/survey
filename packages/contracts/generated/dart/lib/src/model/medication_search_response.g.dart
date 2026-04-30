// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_search_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MedicationSearchResponse extends MedicationSearchResponse {
  @override
  final BuiltList<MedicationSearchItem> results;

  factory _$MedicationSearchResponse(
          [void Function(MedicationSearchResponseBuilder)? updates]) =>
      (MedicationSearchResponseBuilder()..update(updates))._build();

  _$MedicationSearchResponse._({required this.results}) : super._();
  @override
  MedicationSearchResponse rebuild(
          void Function(MedicationSearchResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MedicationSearchResponseBuilder toBuilder() =>
      MedicationSearchResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MedicationSearchResponse && results == other.results;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, results.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MedicationSearchResponse')
          ..add('results', results))
        .toString();
  }
}

class MedicationSearchResponseBuilder
    implements
        Builder<MedicationSearchResponse, MedicationSearchResponseBuilder> {
  _$MedicationSearchResponse? _$v;

  ListBuilder<MedicationSearchItem>? _results;
  ListBuilder<MedicationSearchItem> get results =>
      _$this._results ??= ListBuilder<MedicationSearchItem>();
  set results(ListBuilder<MedicationSearchItem>? results) =>
      _$this._results = results;

  MedicationSearchResponseBuilder() {
    MedicationSearchResponse._defaults(this);
  }

  MedicationSearchResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _results = $v.results.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MedicationSearchResponse other) {
    _$v = other as _$MedicationSearchResponse;
  }

  @override
  void update(void Function(MedicationSearchResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MedicationSearchResponse build() => _build();

  _$MedicationSearchResponse _build() {
    _$MedicationSearchResponse _$result;
    try {
      _$result = _$v ??
          _$MedicationSearchResponse._(
            results: results.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'results';
        results.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MedicationSearchResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
