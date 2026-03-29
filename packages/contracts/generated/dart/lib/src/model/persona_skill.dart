//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/persona_skill_upsert.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'persona_skill.g.dart';

/// PersonaSkill
///
/// Properties:
/// * [personaSkillKey] 
/// * [name] 
/// * [outputProfile] 
/// * [instructions] 
/// * [createdAt] 
/// * [modifiedAt] 
@BuiltValue()
abstract class PersonaSkill implements PersonaSkillUpsert, Built<PersonaSkill, PersonaSkillBuilder> {
  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'modifiedAt')
  DateTime get modifiedAt;

  PersonaSkill._();

  factory PersonaSkill([void updates(PersonaSkillBuilder b)]) = _$PersonaSkill;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PersonaSkillBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PersonaSkill> get serializer => _$PersonaSkillSerializer();
}

class _$PersonaSkillSerializer implements PrimitiveSerializer<PersonaSkill> {
  @override
  final Iterable<Type> types = const [PersonaSkill, _$PersonaSkill];

  @override
  final String wireName = r'PersonaSkill';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PersonaSkill object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
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
    yield r'personaSkillKey';
    yield serializers.serialize(
      object.personaSkillKey,
      specifiedType: const FullType(String),
    );
    yield r'modifiedAt';
    yield serializers.serialize(
      object.modifiedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PersonaSkill object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PersonaSkillBuilder result,
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
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
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
        case r'personaSkillKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.personaSkillKey = valueDes;
          break;
        case r'modifiedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.modifiedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PersonaSkill deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PersonaSkillBuilder();
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

