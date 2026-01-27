//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/address.dart';
import 'package:survey_backend_api/src/model/professional_council.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'screener_register.g.dart';

/// ScreenerRegister
///
/// Properties:
/// * [cpf] - CPF do Screener
/// * [firstName] - Primeiro nome do Screener
/// * [surname] - Sobrenome do Screener
/// * [email] - Endereço de e-mail do Screener
/// * [password] - Senha do Screener
/// * [phone] - Número de telefone do Screener
/// * [address] 
/// * [professionalCouncil] 
/// * [jobTitle] - Cargo/profissão do Screener
/// * [degree] - Formação acadêmica/grau do Screener
/// * [darvCourseYear] - Ano de conclusão do curso DARV (opcional)
@BuiltValue()
abstract class ScreenerRegister implements Built<ScreenerRegister, ScreenerRegisterBuilder> {
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

  /// Senha do Screener
  @BuiltValueField(wireName: r'password')
  String get password;

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

  ScreenerRegister._();

  factory ScreenerRegister([void updates(ScreenerRegisterBuilder b)]) = _$ScreenerRegister;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScreenerRegisterBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScreenerRegister> get serializer => _$ScreenerRegisterSerializer();
}

class _$ScreenerRegisterSerializer implements PrimitiveSerializer<ScreenerRegister> {
  @override
  final Iterable<Type> types = const [ScreenerRegister, _$ScreenerRegister];

  @override
  final String wireName = r'ScreenerRegister';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScreenerRegister object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'password';
    yield serializers.serialize(
      object.password,
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
    ScreenerRegister object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScreenerRegisterBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
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
  ScreenerRegister deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScreenerRegisterBuilder();
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

