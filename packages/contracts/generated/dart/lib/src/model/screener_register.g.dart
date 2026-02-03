// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screener_register.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ScreenerRegister extends ScreenerRegister {
  @override
  final String cpf;
  @override
  final String firstName;
  @override
  final String surname;
  @override
  final String email;
  @override
  final String password;
  @override
  final String phone;
  @override
  final Address address;
  @override
  final ProfessionalCouncil professionalCouncil;
  @override
  final String jobTitle;
  @override
  final String degree;
  @override
  final int? darvCourseYear;

  factory _$ScreenerRegister(
          [void Function(ScreenerRegisterBuilder)? updates]) =>
      (ScreenerRegisterBuilder()..update(updates))._build();

  _$ScreenerRegister._(
      {required this.cpf,
      required this.firstName,
      required this.surname,
      required this.email,
      required this.password,
      required this.phone,
      required this.address,
      required this.professionalCouncil,
      required this.jobTitle,
      required this.degree,
      this.darvCourseYear})
      : super._();
  @override
  ScreenerRegister rebuild(void Function(ScreenerRegisterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScreenerRegisterBuilder toBuilder() =>
      ScreenerRegisterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScreenerRegister &&
        cpf == other.cpf &&
        firstName == other.firstName &&
        surname == other.surname &&
        email == other.email &&
        password == other.password &&
        phone == other.phone &&
        address == other.address &&
        professionalCouncil == other.professionalCouncil &&
        jobTitle == other.jobTitle &&
        degree == other.degree &&
        darvCourseYear == other.darvCourseYear;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cpf.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, surname.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, professionalCouncil.hashCode);
    _$hash = $jc(_$hash, jobTitle.hashCode);
    _$hash = $jc(_$hash, degree.hashCode);
    _$hash = $jc(_$hash, darvCourseYear.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ScreenerRegister')
          ..add('cpf', cpf)
          ..add('firstName', firstName)
          ..add('surname', surname)
          ..add('email', email)
          ..add('password', password)
          ..add('phone', phone)
          ..add('address', address)
          ..add('professionalCouncil', professionalCouncil)
          ..add('jobTitle', jobTitle)
          ..add('degree', degree)
          ..add('darvCourseYear', darvCourseYear))
        .toString();
  }
}

class ScreenerRegisterBuilder
    implements Builder<ScreenerRegister, ScreenerRegisterBuilder> {
  _$ScreenerRegister? _$v;

  String? _cpf;
  String? get cpf => _$this._cpf;
  set cpf(String? cpf) => _$this._cpf = cpf;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _surname;
  String? get surname => _$this._surname;
  set surname(String? surname) => _$this._surname = surname;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  AddressBuilder? _address;
  AddressBuilder get address => _$this._address ??= AddressBuilder();
  set address(AddressBuilder? address) => _$this._address = address;

  ProfessionalCouncilBuilder? _professionalCouncil;
  ProfessionalCouncilBuilder get professionalCouncil =>
      _$this._professionalCouncil ??= ProfessionalCouncilBuilder();
  set professionalCouncil(ProfessionalCouncilBuilder? professionalCouncil) =>
      _$this._professionalCouncil = professionalCouncil;

  String? _jobTitle;
  String? get jobTitle => _$this._jobTitle;
  set jobTitle(String? jobTitle) => _$this._jobTitle = jobTitle;

  String? _degree;
  String? get degree => _$this._degree;
  set degree(String? degree) => _$this._degree = degree;

  int? _darvCourseYear;
  int? get darvCourseYear => _$this._darvCourseYear;
  set darvCourseYear(int? darvCourseYear) =>
      _$this._darvCourseYear = darvCourseYear;

  ScreenerRegisterBuilder() {
    ScreenerRegister._defaults(this);
  }

  ScreenerRegisterBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cpf = $v.cpf;
      _firstName = $v.firstName;
      _surname = $v.surname;
      _email = $v.email;
      _password = $v.password;
      _phone = $v.phone;
      _address = $v.address.toBuilder();
      _professionalCouncil = $v.professionalCouncil.toBuilder();
      _jobTitle = $v.jobTitle;
      _degree = $v.degree;
      _darvCourseYear = $v.darvCourseYear;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScreenerRegister other) {
    _$v = other as _$ScreenerRegister;
  }

  @override
  void update(void Function(ScreenerRegisterBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScreenerRegister build() => _build();

  _$ScreenerRegister _build() {
    _$ScreenerRegister _$result;
    try {
      _$result = _$v ??
          _$ScreenerRegister._(
            cpf: BuiltValueNullFieldError.checkNotNull(
                cpf, r'ScreenerRegister', 'cpf'),
            firstName: BuiltValueNullFieldError.checkNotNull(
                firstName, r'ScreenerRegister', 'firstName'),
            surname: BuiltValueNullFieldError.checkNotNull(
                surname, r'ScreenerRegister', 'surname'),
            email: BuiltValueNullFieldError.checkNotNull(
                email, r'ScreenerRegister', 'email'),
            password: BuiltValueNullFieldError.checkNotNull(
                password, r'ScreenerRegister', 'password'),
            phone: BuiltValueNullFieldError.checkNotNull(
                phone, r'ScreenerRegister', 'phone'),
            address: address.build(),
            professionalCouncil: professionalCouncil.build(),
            jobTitle: BuiltValueNullFieldError.checkNotNull(
                jobTitle, r'ScreenerRegister', 'jobTitle'),
            degree: BuiltValueNullFieldError.checkNotNull(
                degree, r'ScreenerRegister', 'degree'),
            darvCourseYear: darvCourseYear,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'address';
        address.build();
        _$failedField = 'professionalCouncil';
        professionalCouncil.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ScreenerRegister', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
