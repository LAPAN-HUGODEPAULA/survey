//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ai_progress.g.dart';

/// AIProgress
///
/// Properties:
/// * [stage] 
/// * [stageLabel] 
/// * [percent] 
/// * [status] 
/// * [severity] 
/// * [retryable] 
/// * [userMessage] 
/// * [updatedAt] 
@BuiltValue()
abstract class AIProgress implements Built<AIProgress, AIProgressBuilder> {
  @BuiltValueField(wireName: r'stage')
  String? get stage;

  @BuiltValueField(wireName: r'stageLabel')
  String? get stageLabel;

  @BuiltValueField(wireName: r'percent')
  int? get percent;

  @BuiltValueField(wireName: r'status')
  String? get status;

  @BuiltValueField(wireName: r'severity')
  AIProgressSeverityEnum? get severity;
  // enum severityEnum {  info,  success,  warning,  critical,  };

  @BuiltValueField(wireName: r'retryable')
  bool? get retryable;

  @BuiltValueField(wireName: r'userMessage')
  String? get userMessage;

  @BuiltValueField(wireName: r'updatedAt')
  String? get updatedAt;

  AIProgress._();

  factory AIProgress([void updates(AIProgressBuilder b)]) = _$AIProgress;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AIProgressBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AIProgress> get serializer => _$AIProgressSerializer();
}

class _$AIProgressSerializer implements PrimitiveSerializer<AIProgress> {
  @override
  final Iterable<Type> types = const [AIProgress, _$AIProgress];

  @override
  final String wireName = r'AIProgress';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AIProgress object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.stage != null) {
      yield r'stage';
      yield serializers.serialize(
        object.stage,
        specifiedType: const FullType(String),
      );
    }
    if (object.stageLabel != null) {
      yield r'stageLabel';
      yield serializers.serialize(
        object.stageLabel,
        specifiedType: const FullType(String),
      );
    }
    if (object.percent != null) {
      yield r'percent';
      yield serializers.serialize(
        object.percent,
        specifiedType: const FullType(int),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(String),
      );
    }
    if (object.severity != null) {
      yield r'severity';
      yield serializers.serialize(
        object.severity,
        specifiedType: const FullType(AIProgressSeverityEnum),
      );
    }
    if (object.retryable != null) {
      yield r'retryable';
      yield serializers.serialize(
        object.retryable,
        specifiedType: const FullType(bool),
      );
    }
    if (object.userMessage != null) {
      yield r'userMessage';
      yield serializers.serialize(
        object.userMessage,
        specifiedType: const FullType(String),
      );
    }
    if (object.updatedAt != null) {
      yield r'updatedAt';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AIProgress object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AIProgressBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stage = valueDes;
          break;
        case r'stageLabel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stageLabel = valueDes;
          break;
        case r'percent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.percent = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'severity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AIProgressSeverityEnum),
          ) as AIProgressSeverityEnum;
          result.severity = valueDes;
          break;
        case r'retryable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.retryable = valueDes;
          break;
        case r'userMessage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userMessage = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AIProgress deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AIProgressBuilder();
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

class AIProgressSeverityEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'info')
  static const AIProgressSeverityEnum info = _$aIProgressSeverityEnum_info;
  @BuiltValueEnumConst(wireName: r'success')
  static const AIProgressSeverityEnum success = _$aIProgressSeverityEnum_success;
  @BuiltValueEnumConst(wireName: r'warning')
  static const AIProgressSeverityEnum warning = _$aIProgressSeverityEnum_warning;
  @BuiltValueEnumConst(wireName: r'critical')
  static const AIProgressSeverityEnum critical = _$aIProgressSeverityEnum_critical;

  static Serializer<AIProgressSeverityEnum> get serializer => _$aIProgressSeverityEnumSerializer;

  const AIProgressSeverityEnum._(String name): super(name);

  static BuiltSet<AIProgressSeverityEnum> get values => _$aIProgressSeverityEnumValues;
  static AIProgressSeverityEnum valueOf(String name) => _$aIProgressSeverityEnumValueOf(name);
}

