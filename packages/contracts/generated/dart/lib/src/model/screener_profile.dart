//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/address.dart';
import 'package:survey_backend_api/src/model/professional_council.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'screener_profile.g.dart';

/// ScreenerProfile
///
/// Properties:
/// * [id] 
/// * [cpf] - CPF do Screener
/// * [firstName] - Primeiro nome do Screener
/// * [surname] - Sobrenome do Screener
/// * [email] - Endereço de e-mail do Screener
/// * [phone] - Número de telefone do Screener
/// * [address] 
/// * [professionalCouncil] 
/// * [jobTitle] - Cargo/profissão do Screener
/// * [degree] - Formação acadêmica/grau do Screener
/// * [darvCourseYear] - Ano de conclusão do curso DARV (opcional)
@BuiltValue()
abstract class ScreenerProfile implements Built<ScreenerProfile, ScreenerProfileBuilder> {
  @BuiltValueField(wireName: r'_id')
  String get id;

  /// CPF do Screener
  @BuiltValueField(wireName: r'cpf')
  String get cpf;

  /// Primeiro nome do Screener
  @BuiltValueField(wireName: r'firstName')
  String get firstName;

  /// Sobrenome do Screener
  @BuiltValueField(wireName: r'surname')
  String get surname;

  /// Endereço de e-mail do Screener
  @BuiltValueField(wireName: r'email')
  String get email;

  /// Número de telefone do Screener
  @BuiltValueField(wireName: r'phone')
  String get phone;

  @BuiltValueField(wireName: r'address')
  Address get address;

  @BuiltValueField(wireName: r'professionalCouncil')
  ProfessionalCouncil get professionalCouncil;

  /// Cargo/profissão do Screener
  @BuiltValueField(wireName: r'jobTitle')
  String get jobTitle;

  /// Formação acadêmica/grau do Screener
  @BuiltValueField(wireName: r'degree')
  String get degree;

  /// Ano de conclusão do curso DARV (opcional)
  @BuiltValueField(wireName: r'darvCourseYear')
  int? get darvCourseYear;

  ScreenerProfile._();

  factory ScreenerProfile([void updates(ScreenerProfileBuilder b)]) = _$ScreenerProfile;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScreenerProfileBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScreenerProfile> get serializer => _$ScreenerProfileSerializer();
}

class _$ScreenerProfileSerializer implements PrimitiveSerializer<ScreenerProfile> {
  @override
  final Iterable<Type> types = const [ScreenerProfile, _$ScreenerProfile];

  @override
  final String wireName = r'ScreenerProfile';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScreenerProfile object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'_id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'cpf';
    yield serializers.serialize(
      object.cpf,
      specifiedType: const FullType(String),
    );
    yield r'firstName';
    yield serializers.serialize(
      object.firstName,
      specifiedType: const FullType(String),
    );
    yield r'surname';
    yield serializers.serialize(
      object.surname,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
    yield r'address';
    yield serializers.serialize(
      object.address,
      specifiedType: const FullType(Address),
    );
    yield r'professionalCouncil';
    yield serializers.serialize(
      object.professionalCouncil,
      specifiedType: const FullType(ProfessionalCouncil),
    );
    yield r'jobTitle';
    yield serializers.serialize(
      object.jobTitle,
      specifiedType: const FullType(String),
    );
    yield r'degree';
    yield serializers.serialize(
      object.degree,
      specifiedType: const FullType(String),
    );
    if (object.darvCourseYear != null) {
      yield r'darvCourseYear';
      yield serializers.serialize(
        object.darvCourseYear,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ScreenerProfile object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScreenerProfileBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'cpf':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cpf = valueDes;
          break;
        case r'firstName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.firstName = valueDes;
          break;
        case r'surname':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.surname = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        case r'address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Address),
          ) as Address;
          result.address.replace(valueDes);
          break;
        case r'professionalCouncil':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProfessionalCouncil),
          ) as ProfessionalCouncil;
          result.professionalCouncil.replace(valueDes);
          break;
        case r'jobTitle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.jobTitle = valueDes;
          break;
        case r'degree':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.degree = valueDes;
          break;
        case r'darvCourseYear':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.darvCourseYear = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ScreenerProfile deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScreenerProfileBuilder();
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

