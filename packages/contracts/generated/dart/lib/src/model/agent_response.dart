//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'agent_response.g.dart';

/// AgentResponse
///
/// Properties:
/// * [ok] 
/// * [inputType] 
/// * [promptVersion] 
/// * [modelVersion] 
/// * [report] 
/// * [warnings] 
/// * [classification] 
/// * [medicalRecord] 
/// * [errorMessage] 
@BuiltValue()
abstract class AgentResponse implements Built<AgentResponse, AgentResponseBuilder> {
  @BuiltValueField(wireName: r'ok')
  bool? get ok;

  @BuiltValueField(wireName: r'input_type')
  String? get inputType;

  @BuiltValueField(wireName: r'prompt_version')
  String? get promptVersion;

  @BuiltValueField(wireName: r'model_version')
  String? get modelVersion;

  @BuiltValueField(wireName: r'report')
  JsonObject? get report;

  @BuiltValueField(wireName: r'warnings')
  BuiltList<String>? get warnings;

  @BuiltValueField(wireName: r'classification')
  String? get classification;

  @BuiltValueField(wireName: r'medicalRecord')
  String? get medicalRecord;

  @BuiltValueField(wireName: r'errorMessage')
  String? get errorMessage;

  AgentResponse._();

  factory AgentResponse([void updates(AgentResponseBuilder b)]) = _$AgentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AgentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AgentResponse> get serializer => _$AgentResponseSerializer();
}

class _$AgentResponseSerializer implements PrimitiveSerializer<AgentResponse> {
  @override
  final Iterable<Type> types = const [AgentResponse, _$AgentResponse];

  @override
  final String wireName = r'AgentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AgentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.ok != null) {
      yield r'ok';
      yield serializers.serialize(
        object.ok,
        specifiedType: const FullType(bool),
      );
    }
    if (object.inputType != null) {
      yield r'input_type';
      yield serializers.serialize(
        object.inputType,
        specifiedType: const FullType(String),
      );
    }
    if (object.promptVersion != null) {
      yield r'prompt_version';
      yield serializers.serialize(
        object.promptVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.modelVersion != null) {
      yield r'model_version';
      yield serializers.serialize(
        object.modelVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.report != null) {
      yield r'report';
      yield serializers.serialize(
        object.report,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.warnings != null) {
      yield r'warnings';
      yield serializers.serialize(
        object.warnings,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.classification != null) {
      yield r'classification';
      yield serializers.serialize(
        object.classification,
        specifiedType: const FullType(String),
      );
    }
    if (object.medicalRecord != null) {
      yield r'medicalRecord';
      yield serializers.serialize(
        object.medicalRecord,
        specifiedType: const FullType(String),
      );
    }
    if (object.errorMessage != null) {
      yield r'errorMessage';
      yield serializers.serialize(
        object.errorMessage,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AgentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AgentResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ok':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.ok = valueDes;
          break;
        case r'input_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.inputType = valueDes;
          break;
        case r'prompt_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.promptVersion = valueDes;
          break;
        case r'model_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.modelVersion = valueDes;
          break;
        case r'report':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.report = valueDes;
          break;
        case r'warnings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.warnings.replace(valueDes);
          break;
        case r'classification':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.classification = valueDes;
          break;
        case r'medicalRecord':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.medicalRecord = valueDes;
          break;
        case r'errorMessage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.errorMessage = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AgentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AgentResponseBuilder();
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

