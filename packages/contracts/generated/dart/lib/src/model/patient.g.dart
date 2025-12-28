// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Patient extends Patient {
  @override
  final String? name;
  @override
  final String? email;
  @override
  final String? birthDate;
  @override
  final int? age;
  @override
  final String? gender;
  @override
  final String? ethnicity;
  @override
  final String? educationLevel;
  @override
  final String? profession;
  @override
  final BuiltList<String>? medication;
  @override
  final BuiltList<String>? diagnoses;
  @override
  final String? familyHistory;
  @override
  final String? socialHistory;
  @override
  final String? medicalHistory;
  @override
  final String? medicationHistory;

  factory _$Patient([void Function(PatientBuilder)? updates]) =>
      (PatientBuilder()..update(updates))._build();

  _$Patient._(
      {this.name,
      this.email,
      this.birthDate,
      this.age,
      this.gender,
      this.ethnicity,
      this.educationLevel,
      this.profession,
      this.medication,
      this.diagnoses,
      this.familyHistory,
      this.socialHistory,
      this.medicalHistory,
      this.medicationHistory})
      : super._();
  @override
  Patient rebuild(void Function(PatientBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatientBuilder toBuilder() => PatientBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Patient &&
        name == other.name &&
        email == other.email &&
        birthDate == other.birthDate &&
        age == other.age &&
        gender == other.gender &&
        ethnicity == other.ethnicity &&
        educationLevel == other.educationLevel &&
        profession == other.profession &&
        medication == other.medication &&
        diagnoses == other.diagnoses &&
        familyHistory == other.familyHistory &&
        socialHistory == other.socialHistory &&
        medicalHistory == other.medicalHistory &&
        medicationHistory == other.medicationHistory;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, birthDate.hashCode);
    _$hash = $jc(_$hash, age.hashCode);
    _$hash = $jc(_$hash, gender.hashCode);
    _$hash = $jc(_$hash, ethnicity.hashCode);
    _$hash = $jc(_$hash, educationLevel.hashCode);
    _$hash = $jc(_$hash, profession.hashCode);
    _$hash = $jc(_$hash, medication.hashCode);
    _$hash = $jc(_$hash, diagnoses.hashCode);
    _$hash = $jc(_$hash, familyHistory.hashCode);
    _$hash = $jc(_$hash, socialHistory.hashCode);
    _$hash = $jc(_$hash, medicalHistory.hashCode);
    _$hash = $jc(_$hash, medicationHistory.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Patient')
          ..add('name', name)
          ..add('email', email)
          ..add('birthDate', birthDate)
          ..add('age', age)
          ..add('gender', gender)
          ..add('ethnicity', ethnicity)
          ..add('educationLevel', educationLevel)
          ..add('profession', profession)
          ..add('medication', medication)
          ..add('diagnoses', diagnoses)
          ..add('familyHistory', familyHistory)
          ..add('socialHistory', socialHistory)
          ..add('medicalHistory', medicalHistory)
          ..add('medicationHistory', medicationHistory))
        .toString();
  }
}

class PatientBuilder implements Builder<Patient, PatientBuilder> {
  _$Patient? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _birthDate;
  String? get birthDate => _$this._birthDate;
  set birthDate(String? birthDate) => _$this._birthDate = birthDate;

  int? _age;
  int? get age => _$this._age;
  set age(int? age) => _$this._age = age;

  String? _gender;
  String? get gender => _$this._gender;
  set gender(String? gender) => _$this._gender = gender;

  String? _ethnicity;
  String? get ethnicity => _$this._ethnicity;
  set ethnicity(String? ethnicity) => _$this._ethnicity = ethnicity;

  String? _educationLevel;
  String? get educationLevel => _$this._educationLevel;
  set educationLevel(String? educationLevel) =>
      _$this._educationLevel = educationLevel;

  String? _profession;
  String? get profession => _$this._profession;
  set profession(String? profession) => _$this._profession = profession;

  ListBuilder<String>? _medication;
  ListBuilder<String> get medication =>
      _$this._medication ??= ListBuilder<String>();
  set medication(ListBuilder<String>? medication) =>
      _$this._medication = medication;

  ListBuilder<String>? _diagnoses;
  ListBuilder<String> get diagnoses =>
      _$this._diagnoses ??= ListBuilder<String>();
  set diagnoses(ListBuilder<String>? diagnoses) =>
      _$this._diagnoses = diagnoses;

  String? _familyHistory;
  String? get familyHistory => _$this._familyHistory;
  set familyHistory(String? familyHistory) =>
      _$this._familyHistory = familyHistory;

  String? _socialHistory;
  String? get socialHistory => _$this._socialHistory;
  set socialHistory(String? socialHistory) =>
      _$this._socialHistory = socialHistory;

  String? _medicalHistory;
  String? get medicalHistory => _$this._medicalHistory;
  set medicalHistory(String? medicalHistory) =>
      _$this._medicalHistory = medicalHistory;

  String? _medicationHistory;
  String? get medicationHistory => _$this._medicationHistory;
  set medicationHistory(String? medicationHistory) =>
      _$this._medicationHistory = medicationHistory;

  PatientBuilder() {
    Patient._defaults(this);
  }

  PatientBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _email = $v.email;
      _birthDate = $v.birthDate;
      _age = $v.age;
      _gender = $v.gender;
      _ethnicity = $v.ethnicity;
      _educationLevel = $v.educationLevel;
      _profession = $v.profession;
      _medication = $v.medication?.toBuilder();
      _diagnoses = $v.diagnoses?.toBuilder();
      _familyHistory = $v.familyHistory;
      _socialHistory = $v.socialHistory;
      _medicalHistory = $v.medicalHistory;
      _medicationHistory = $v.medicationHistory;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Patient other) {
    _$v = other as _$Patient;
  }

  @override
  void update(void Function(PatientBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Patient build() => _build();

  _$Patient _build() {
    _$Patient _$result;
    try {
      _$result = _$v ??
          _$Patient._(
            name: name,
            email: email,
            birthDate: birthDate,
            age: age,
            gender: gender,
            ethnicity: ethnicity,
            educationLevel: educationLevel,
            profession: profession,
            medication: _medication?.build(),
            diagnoses: _diagnoses?.build(),
            familyHistory: familyHistory,
            socialHistory: socialHistory,
            medicalHistory: medicalHistory,
            medicationHistory: medicationHistory,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'medication';
        _medication?.build();
        _$failedField = 'diagnoses';
        _diagnoses?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Patient', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
