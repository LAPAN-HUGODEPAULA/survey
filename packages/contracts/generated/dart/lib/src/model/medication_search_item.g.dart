// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_search_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MedicationSearchItem extends MedicationSearchItem {
  @override
  final String substance;
  @override
  final String category;
  @override
  final BuiltList<String> tradeNames;

  factory _$MedicationSearchItem(
          [void Function(MedicationSearchItemBuilder)? updates]) =>
      (MedicationSearchItemBuilder()..update(updates))._build();

  _$MedicationSearchItem._(
      {required this.substance,
      required this.category,
      required this.tradeNames})
      : super._();
  @override
  MedicationSearchItem rebuild(
          void Function(MedicationSearchItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MedicationSearchItemBuilder toBuilder() =>
      MedicationSearchItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MedicationSearchItem &&
        substance == other.substance &&
        category == other.category &&
        tradeNames == other.tradeNames;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, substance.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, tradeNames.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MedicationSearchItem')
          ..add('substance', substance)
          ..add('category', category)
          ..add('tradeNames', tradeNames))
        .toString();
  }
}

class MedicationSearchItemBuilder
    implements Builder<MedicationSearchItem, MedicationSearchItemBuilder> {
  _$MedicationSearchItem? _$v;

  String? _substance;
  String? get substance => _$this._substance;
  set substance(String? substance) => _$this._substance = substance;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  ListBuilder<String>? _tradeNames;
  ListBuilder<String> get tradeNames =>
      _$this._tradeNames ??= ListBuilder<String>();
  set tradeNames(ListBuilder<String>? tradeNames) =>
      _$this._tradeNames = tradeNames;

  MedicationSearchItemBuilder() {
    MedicationSearchItem._defaults(this);
  }

  MedicationSearchItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _substance = $v.substance;
      _category = $v.category;
      _tradeNames = $v.tradeNames.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MedicationSearchItem other) {
    _$v = other as _$MedicationSearchItem;
  }

  @override
  void update(void Function(MedicationSearchItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MedicationSearchItem build() => _build();

  _$MedicationSearchItem _build() {
    _$MedicationSearchItem _$result;
    try {
      _$result = _$v ??
          _$MedicationSearchItem._(
            substance: BuiltValueNullFieldError.checkNotNull(
                substance, r'MedicationSearchItem', 'substance'),
            category: BuiltValueNullFieldError.checkNotNull(
                category, r'MedicationSearchItem', 'category'),
            tradeNames: tradeNames.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tradeNames';
        tradeNames.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MedicationSearchItem', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
