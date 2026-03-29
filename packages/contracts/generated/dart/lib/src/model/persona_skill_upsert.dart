//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'persona_skill_upsert.g.dart';

/// PersonaSkillUpsert
///
/// Properties:
/// * [personaSkillKey] 
/// * [name] 
/// * [outputProfile] 
/// * [instructions] 
@BuiltValue(instantiable: false)
abstract class PersonaSkillUpsert  {
  @BuiltValueField(wireName: r'personaSkillKey')
  String get personaSkillKey;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'outputProfile')
  String get outputProfile;

  @BuiltValueField(wireName: r'instructions')
  String get instructions;

  @BuiltValueSerializer(custom: true)
  static Serializer<PersonaSkillUpsert> get serializer => _$PersonaSkillUpsertSerializer();
}

class _$PersonaSkillUpsertSerializer implements PrimitiveSerializer<PersonaSkillUpsert> {
  @override
  final Iterable<Type> types = const [PersonaSkillUpsert];

  @override
  final String wireName = r'PersonaSkillUpsert';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PersonaSkillUpsert object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'personaSkillKey';
    yield serializers.serialize(
      object.personaSkillKey,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'outputProfile';
    yield serializers.serialize(
      object.outputProfile,
      specifiedType: const FullType(String),
    );
    yield r'instructions';
    yield serializers.serialize(
      object.instructions,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PersonaSkillUpsert object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  PersonaSkillUpsert deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($PersonaSkillUpsert)) as $PersonaSkillUpsert;
  }
}

/// a concrete implementation of [PersonaSkillUpsert], since [PersonaSkillUpsert] is not instantiable
@BuiltValue(instantiable: true)
abstract class $PersonaSkillUpsert implements PersonaSkillUpsert, Built<$PersonaSkillUpsert, $PersonaSkillUpsertBuilder> {
  $PersonaSkillUpsert._();

  factory $PersonaSkillUpsert([void Function($PersonaSkillUpsertBuilder)? updates]) = _$$PersonaSkillUpsert;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($PersonaSkillUpsertBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$PersonaSkillUpsert> get serializer => _$$PersonaSkillUpsertSerializer();
}

class _$$PersonaSkillUpsertSerializer implements PrimitiveSerializer<$PersonaSkillUpsert> {
  @override
  final Iterable<Type> types = const [$PersonaSkillUpsert, _$$PersonaSkillUpsert];

  @override
  final String wireName = r'$PersonaSkillUpsert';

  @override
  Object serialize(
    Serializers serializers,
    $PersonaSkillUpsert object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(PersonaSkillUpsert))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PersonaSkillUpsertBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'personaSkillKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.personaSkillKey = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'outputProfile':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.outputProfile = valueDes;
          break;
        case r'instructions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.instructions = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  $PersonaSkillUpsert deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $PersonaSkillUpsertBuilder();
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

