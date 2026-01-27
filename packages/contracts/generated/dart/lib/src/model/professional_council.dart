//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'professional_council.g.dart';

/// ProfessionalCouncil
///
/// Properties:
/// * [type] - Tipo do conselho profissional (ex: CRP, CRM)
/// * [registrationNumber] - Número de registro no conselho profissional
@BuiltValue()
abstract class ProfessionalCouncil implements Built<ProfessionalCouncil, ProfessionalCouncilBuilder> {
  /// Tipo do conselho profissional (ex: CRP, CRM)
  @BuiltValueField(wireName: r'type')
  ProfessionalCouncilTypeEnum? get type;
  // enum typeEnum {  CFEP,  CRP,  COREN,  CRM,  CREFITO,  CREFONO,  CRN,  none,  };

  /// Número de registro no conselho profissional
  @BuiltValueField(wireName: r'registrationNumber')
  String? get registrationNumber;

  ProfessionalCouncil._();

  factory ProfessionalCouncil([void updates(ProfessionalCouncilBuilder b)]) = _$ProfessionalCouncil;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProfessionalCouncilBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProfessionalCouncil> get serializer => _$ProfessionalCouncilSerializer();
}

class _$ProfessionalCouncilSerializer implements PrimitiveSerializer<ProfessionalCouncil> {
  @override
  final Iterable<Type> types = const [ProfessionalCouncil, _$ProfessionalCouncil];

  @override
  final String wireName = r'ProfessionalCouncil';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProfessionalCouncil object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(ProfessionalCouncilTypeEnum),
      );
    }
    if (object.registrationNumber != null) {
      yield r'registrationNumber';
      yield serializers.serialize(
        object.registrationNumber,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProfessionalCouncil object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProfessionalCouncilBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProfessionalCouncilTypeEnum),
          ) as ProfessionalCouncilTypeEnum;
          result.type = valueDes;
          break;
        case r'registrationNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.registrationNumber = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProfessionalCouncil deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProfessionalCouncilBuilder();
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

class ProfessionalCouncilTypeEnum extends EnumClass {

  /// Tipo do conselho profissional (ex: CRP, CRM)
  @BuiltValueEnumConst(wireName: r'CFEP')
  static const ProfessionalCouncilTypeEnum CFEP = _$professionalCouncilTypeEnum_CFEP;
  /// Tipo do conselho profissional (ex: CRP, CRM)
  @BuiltValueEnumConst(wireName: r'CRP')
  static const ProfessionalCouncilTypeEnum CRP = _$professionalCouncilTypeEnum_CRP;
  /// Tipo do conselho profissional (ex: CRP, CRM)
  @BuiltValueEnumConst(wireName: r'COREN')
  static const ProfessionalCouncilTypeEnum COREN = _$professionalCouncilTypeEnum_COREN;
  /// Tipo do conselho profissional (ex: CRP, CRM)
  @BuiltValueEnumConst(wireName: r'CRM')
  static const ProfessionalCouncilTypeEnum CRM = _$professionalCouncilTypeEnum_CRM;
  /// Tipo do conselho profissional (ex: CRP, CRM)
  @BuiltValueEnumConst(wireName: r'CREFITO')
  static const ProfessionalCouncilTypeEnum CREFITO = _$professionalCouncilTypeEnum_CREFITO;
  /// Tipo do conselho profissional (ex: CRP, CRM)
  @BuiltValueEnumConst(wireName: r'CREFONO')
  static const ProfessionalCouncilTypeEnum CREFONO = _$professionalCouncilTypeEnum_CREFONO;
  /// Tipo do conselho profissional (ex: CRP, CRM)
  @BuiltValueEnumConst(wireName: r'CRN')
  static const ProfessionalCouncilTypeEnum CRN = _$professionalCouncilTypeEnum_CRN;
  /// Tipo do conselho profissional (ex: CRP, CRM)
  @BuiltValueEnumConst(wireName: r'none')
  static const ProfessionalCouncilTypeEnum none = _$professionalCouncilTypeEnum_none;

  static Serializer<ProfessionalCouncilTypeEnum> get serializer => _$professionalCouncilTypeEnumSerializer;

  const ProfessionalCouncilTypeEnum._(String name): super(name);

  static BuiltSet<ProfessionalCouncilTypeEnum> get values => _$professionalCouncilTypeEnumValues;
  static ProfessionalCouncilTypeEnum valueOf(String name) => _$professionalCouncilTypeEnumValueOf(name);
}

