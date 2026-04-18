//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'agent_access_point_upsert.g.dart';

/// AgentAccessPointUpsert
///
/// Properties:
/// * [accessPointKey]
/// * [name]
/// * [sourceApp]
/// * [flowKey]
/// * [promptKey]
/// * [personaSkillKey]
/// * [outputProfile]
/// * [surveyId]
/// * [description]
@BuiltValue(instantiable: false)
abstract class AgentAccessPointUpsert {
  @BuiltValueField(wireName: r'accessPointKey')
  String get accessPointKey;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'sourceApp')
  String get sourceApp;

  @BuiltValueField(wireName: r'flowKey')
  String get flowKey;

  @BuiltValueField(wireName: r'promptKey')
  String get promptKey;

  @BuiltValueField(wireName: r'personaSkillKey')
  String get personaSkillKey;

  @BuiltValueField(wireName: r'outputProfile')
  String get outputProfile;

  @BuiltValueField(wireName: r'surveyId')
  String? get surveyId;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueSerializer(custom: true)
  static Serializer<AgentAccessPointUpsert> get serializer => _$AgentAccessPointUpsertSerializer();
}

class _$AgentAccessPointUpsertSerializer implements PrimitiveSerializer<AgentAccessPointUpsert> {
  @override
  final Iterable<Type> types = const [AgentAccessPointUpsert];

  @override
  final String wireName = r'AgentAccessPointUpsert';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AgentAccessPointUpsert object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'accessPointKey';
    yield serializers.serialize(
      object.accessPointKey,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'sourceApp';
    yield serializers.serialize(
      object.sourceApp,
      specifiedType: const FullType(String),
    );
    yield r'flowKey';
    yield serializers.serialize(
      object.flowKey,
      specifiedType: const FullType(String),
    );
    yield r'promptKey';
    yield serializers.serialize(
      object.promptKey,
      specifiedType: const FullType(String),
    );
    yield r'personaSkillKey';
    yield serializers.serialize(
      object.personaSkillKey,
      specifiedType: const FullType(String),
    );
    yield r'outputProfile';
    yield serializers.serialize(
      object.outputProfile,
      specifiedType: const FullType(String),
    );
    if (object.surveyId != null) {
      yield r'surveyId';
      yield serializers.serialize(
        object.surveyId,
        specifiedType: const FullType(String),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AgentAccessPointUpsert object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  AgentAccessPointUpsert deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($AgentAccessPointUpsert)) as $AgentAccessPointUpsert;
  }
}

/// a concrete implementation of [AgentAccessPointUpsert], since [AgentAccessPointUpsert] is not instantiable
@BuiltValue(instantiable: true)
abstract class $AgentAccessPointUpsert implements AgentAccessPointUpsert, Built<$AgentAccessPointUpsert, $AgentAccessPointUpsertBuilder> {
  $AgentAccessPointUpsert._();

  factory $AgentAccessPointUpsert([void Function($AgentAccessPointUpsertBuilder)? updates]) = _$$AgentAccessPointUpsert;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($AgentAccessPointUpsertBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$AgentAccessPointUpsert> get serializer => _$$AgentAccessPointUpsertSerializer();
}

class _$$AgentAccessPointUpsertSerializer implements PrimitiveSerializer<$AgentAccessPointUpsert> {
  @override
  final Iterable<Type> types = const [$AgentAccessPointUpsert, _$$AgentAccessPointUpsert];

  @override
  final String wireName = r'$AgentAccessPointUpsert';

  @override
  Object serialize(
    Serializers serializers,
    $AgentAccessPointUpsert object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(AgentAccessPointUpsert))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AgentAccessPointUpsertBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accessPointKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessPointKey = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'sourceApp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceApp = valueDes;
          break;
        case r'flowKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.flowKey = valueDes;
          break;
        case r'promptKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.promptKey = valueDes;
          break;
        case r'personaSkillKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.personaSkillKey = valueDes;
          break;
        case r'outputProfile':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.outputProfile = valueDes;
          break;
        case r'surveyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.surveyId = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  $AgentAccessPointUpsert deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $AgentAccessPointUpsertBuilder();
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
