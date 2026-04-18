//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/agent_access_point_upsert.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'agent_access_point.g.dart';

/// AgentAccessPoint
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
/// * [createdAt]
/// * [modifiedAt]
@BuiltValue()
abstract class AgentAccessPoint implements AgentAccessPointUpsert, Built<AgentAccessPoint, AgentAccessPointBuilder> {
  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'modifiedAt')
  DateTime get modifiedAt;

  AgentAccessPoint._();

  factory AgentAccessPoint([void updates(AgentAccessPointBuilder b)]) = _$AgentAccessPoint;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AgentAccessPointBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AgentAccessPoint> get serializer => _$AgentAccessPointSerializer();
}

class _$AgentAccessPointSerializer implements PrimitiveSerializer<AgentAccessPoint> {
  @override
  final Iterable<Type> types = const [AgentAccessPoint, _$AgentAccessPoint];

  @override
  final String wireName = r'AgentAccessPoint';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AgentAccessPoint object, {
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
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
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
    AgentAccessPoint object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AgentAccessPointBuilder result,
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
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
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
  AgentAccessPoint deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AgentAccessPointBuilder();
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
