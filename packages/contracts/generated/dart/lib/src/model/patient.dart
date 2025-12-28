//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'patient.g.dart';

/// Patient
///
/// Properties:
/// * [name] 
/// * [email] 
/// * [birthDate] 
/// * [age] 
/// * [gender] 
/// * [ethnicity] 
/// * [educationLevel] 
/// * [profession] 
/// * [medication] 
/// * [diagnoses] 
/// * [familyHistory] 
/// * [socialHistory] 
/// * [medicalHistory] 
/// * [medicationHistory] 
@BuiltValue()
abstract class Patient implements Built<Patient, PatientBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'birthDate')
  String? get birthDate;

  @BuiltValueField(wireName: r'age')
  int? get age;

  @BuiltValueField(wireName: r'gender')
  String? get gender;

  @BuiltValueField(wireName: r'ethnicity')
  String? get ethnicity;

  @BuiltValueField(wireName: r'educationLevel')
  String? get educationLevel;

  @BuiltValueField(wireName: r'profession')
  String? get profession;

  @BuiltValueField(wireName: r'medication')
  BuiltList<String>? get medication;

  @BuiltValueField(wireName: r'diagnoses')
  BuiltList<String>? get diagnoses;

  @BuiltValueField(wireName: r'family_history')
  String? get familyHistory;

  @BuiltValueField(wireName: r'social_history')
  String? get socialHistory;

  @BuiltValueField(wireName: r'medical_history')
  String? get medicalHistory;

  @BuiltValueField(wireName: r'medication_history')
  String? get medicationHistory;

  Patient._();

  factory Patient([void updates(PatientBuilder b)]) = _$Patient;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatientBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Patient> get serializer => _$PatientSerializer();
}

class _$PatientSerializer implements PrimitiveSerializer<Patient> {
  @override
  final Iterable<Type> types = const [Patient, _$Patient];

  @override
  final String wireName = r'Patient';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Patient object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      );
    }
    if (object.birthDate != null) {
      yield r'birthDate';
      yield serializers.serialize(
        object.birthDate,
        specifiedType: const FullType(String),
      );
    }
    if (object.age != null) {
      yield r'age';
      yield serializers.serialize(
        object.age,
        specifiedType: const FullType(int),
      );
    }
    if (object.gender != null) {
      yield r'gender';
      yield serializers.serialize(
        object.gender,
        specifiedType: const FullType(String),
      );
    }
    if (object.ethnicity != null) {
      yield r'ethnicity';
      yield serializers.serialize(
        object.ethnicity,
        specifiedType: const FullType(String),
      );
    }
    if (object.educationLevel != null) {
      yield r'educationLevel';
      yield serializers.serialize(
        object.educationLevel,
        specifiedType: const FullType(String),
      );
    }
    if (object.profession != null) {
      yield r'profession';
      yield serializers.serialize(
        object.profession,
        specifiedType: const FullType(String),
      );
    }
    if (object.medication != null) {
      yield r'medication';
      yield serializers.serialize(
        object.medication,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.diagnoses != null) {
      yield r'diagnoses';
      yield serializers.serialize(
        object.diagnoses,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.familyHistory != null) {
      yield r'family_history';
      yield serializers.serialize(
        object.familyHistory,
        specifiedType: const FullType(String),
      );
    }
    if (object.socialHistory != null) {
      yield r'social_history';
      yield serializers.serialize(
        object.socialHistory,
        specifiedType: const FullType(String),
      );
    }
    if (object.medicalHistory != null) {
      yield r'medical_history';
      yield serializers.serialize(
        object.medicalHistory,
        specifiedType: const FullType(String),
      );
    }
    if (object.medicationHistory != null) {
      yield r'medication_history';
      yield serializers.serialize(
        object.medicationHistory,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Patient object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PatientBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'birthDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.birthDate = valueDes;
          break;
        case r'age':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.age = valueDes;
          break;
        case r'gender':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.gender = valueDes;
          break;
        case r'ethnicity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ethnicity = valueDes;
          break;
        case r'educationLevel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.educationLevel = valueDes;
          break;
        case r'profession':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.profession = valueDes;
          break;
        case r'medication':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.medication.replace(valueDes);
          break;
        case r'diagnoses':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.diagnoses.replace(valueDes);
          break;
        case r'family_history':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.familyHistory = valueDes;
          break;
        case r'social_history':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.socialHistory = valueDes;
          break;
        case r'medical_history':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.medicalHistory = valueDes;
          break;
        case r'medication_history':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.medicationHistory = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Patient deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatientBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

