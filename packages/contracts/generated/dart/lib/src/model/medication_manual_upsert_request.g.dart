// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_manual_upsert_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MedicationManualUpsertRequest extends MedicationManualUpsertRequest {
  @override
  final String substance;

  factory _$MedicationManualUpsertRequest(
          [void Function(MedicationManualUpsertRequestBuilder)? updates]) =>
      (MedicationManualUpsertRequestBuilder()..update(updates))._build();

  _$MedicationManualUpsertRequest._({required this.substance}) : super._();
  @override
  MedicationManualUpsertRequest rebuild(
          void Function(MedicationManualUpsertRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MedicationManualUpsertRequestBuilder toBuilder() =>
      MedicationManualUpsertRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MedicationManualUpsertRequest &&
        substance == other.substance;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, substance.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MedicationManualUpsertRequest')
          ..add('substance', substance))
        .toString();
  }
}

class MedicationManualUpsertRequestBuilder
    implements
        Builder<MedicationManualUpsertRequest,
            MedicationManualUpsertRequestBuilder> {
  _$MedicationManualUpsertRequest? _$v;

  String? _substance;
  String? get substance => _$this._substance;
  set substance(String? substance) => _$this._substance = substance;

  MedicationManualUpsertRequestBuilder() {
    MedicationManualUpsertRequest._defaults(this);
  }

  MedicationManualUpsertRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _substance = $v.substance;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MedicationManualUpsertRequest other) {
    _$v = other as _$MedicationManualUpsertRequest;
  }

  @override
  void update(void Function(MedicationManualUpsertRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MedicationManualUpsertRequest build() => _build();

  _$MedicationManualUpsertRequest _build() {
    final _$result = _$v ??
        _$MedicationManualUpsertRequest._(
          substance: BuiltValueNullFieldError.checkNotNull(
              substance, r'MedicationManualUpsertRequest', 'substance'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
