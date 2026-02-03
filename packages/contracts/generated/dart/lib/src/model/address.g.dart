// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Address extends Address {
  @override
  final String postalCode;
  @override
  final String street;
  @override
  final String number;
  @override
  final String? complement;
  @override
  final String neighborhood;
  @override
  final String city;
  @override
  final String state;

  factory _$Address([void Function(AddressBuilder)? updates]) =>
      (AddressBuilder()..update(updates))._build();

  _$Address._(
      {required this.postalCode,
      required this.street,
      required this.number,
      this.complement,
      required this.neighborhood,
      required this.city,
      required this.state})
      : super._();
  @override
  Address rebuild(void Function(AddressBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AddressBuilder toBuilder() => AddressBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Address &&
        postalCode == other.postalCode &&
        street == other.street &&
        number == other.number &&
        complement == other.complement &&
        neighborhood == other.neighborhood &&
        city == other.city &&
        state == other.state;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, postalCode.hashCode);
    _$hash = $jc(_$hash, street.hashCode);
    _$hash = $jc(_$hash, number.hashCode);
    _$hash = $jc(_$hash, complement.hashCode);
    _$hash = $jc(_$hash, neighborhood.hashCode);
    _$hash = $jc(_$hash, city.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Address')
          ..add('postalCode', postalCode)
          ..add('street', street)
          ..add('number', number)
          ..add('complement', complement)
          ..add('neighborhood', neighborhood)
          ..add('city', city)
          ..add('state', state))
        .toString();
  }
}

class AddressBuilder implements Builder<Address, AddressBuilder> {
  _$Address? _$v;

  String? _postalCode;
  String? get postalCode => _$this._postalCode;
  set postalCode(String? postalCode) => _$this._postalCode = postalCode;

  String? _street;
  String? get street => _$this._street;
  set street(String? street) => _$this._street = street;

  String? _number;
  String? get number => _$this._number;
  set number(String? number) => _$this._number = number;

  String? _complement;
  String? get complement => _$this._complement;
  set complement(String? complement) => _$this._complement = complement;

  String? _neighborhood;
  String? get neighborhood => _$this._neighborhood;
  set neighborhood(String? neighborhood) => _$this._neighborhood = neighborhood;

  String? _city;
  String? get city => _$this._city;
  set city(String? city) => _$this._city = city;

  String? _state;
  String? get state => _$this._state;
  set state(String? state) => _$this._state = state;

  AddressBuilder() {
    Address._defaults(this);
  }

  AddressBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _postalCode = $v.postalCode;
      _street = $v.street;
      _number = $v.number;
      _complement = $v.complement;
      _neighborhood = $v.neighborhood;
      _city = $v.city;
      _state = $v.state;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Address other) {
    _$v = other as _$Address;
  }

  @override
  void update(void Function(AddressBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Address build() => _build();

  _$Address _build() {
    final _$result = _$v ??
        _$Address._(
          postalCode: BuiltValueNullFieldError.checkNotNull(
              postalCode, r'Address', 'postalCode'),
          street: BuiltValueNullFieldError.checkNotNull(
              street, r'Address', 'street'),
          number: BuiltValueNullFieldError.checkNotNull(
              number, r'Address', 'number'),
          complement: complement,
          neighborhood: BuiltValueNullFieldError.checkNotNull(
              neighborhood, r'Address', 'neighborhood'),
          city: BuiltValueNullFieldError.checkNotNull(city, r'Address', 'city'),
          state:
              BuiltValueNullFieldError.checkNotNull(state, r'Address', 'state'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
