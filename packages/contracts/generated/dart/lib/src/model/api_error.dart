//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'api_error.g.dart';

/// ApiError
///
/// Properties:
/// * [code] - Stable string identifier for the error category
/// * [userMessage] - Localized, human-readable message in pt-BR
/// * [severity] 
/// * [retryable] 
/// * [requestId] 
/// * [operation] 
/// * [stage] 
/// * [details] 
@BuiltValue()
abstract class ApiError implements Built<ApiError, ApiErrorBuilder> {
  /// Stable string identifier for the error category
  @BuiltValueField(wireName: r'code')
  String get code;

  /// Localized, human-readable message in pt-BR
  @BuiltValueField(wireName: r'userMessage')
  String get userMessage;

  @BuiltValueField(wireName: r'severity')
  ApiErrorSeverityEnum? get severity;
  // enum severityEnum {  info,  warning,  error,  critical,  };

  @BuiltValueField(wireName: r'retryable')
  bool? get retryable;

  @BuiltValueField(wireName: r'requestId')
  String? get requestId;

  @BuiltValueField(wireName: r'operation')
  String? get operation;

  @BuiltValueField(wireName: r'stage')
  String? get stage;

  @BuiltValueField(wireName: r'details')
  BuiltList<JsonObject>? get details;

  ApiError._();

  factory ApiError([void updates(ApiErrorBuilder b)]) = _$ApiError;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApiErrorBuilder b) => b
      ..severity = const ApiErrorSeverityEnum._('error')
      ..retryable = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApiError> get serializer => _$ApiErrorSerializer();
}

class _$ApiErrorSerializer implements PrimitiveSerializer<ApiError> {
  @override
  final Iterable<Type> types = const [ApiError, _$ApiError];

  @override
  final String wireName = r'ApiError';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApiError object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'userMessage';
    yield serializers.serialize(
      object.userMessage,
      specifiedType: const FullType(String),
    );
    if (object.severity != null) {
      yield r'severity';
      yield serializers.serialize(
        object.severity,
        specifiedType: const FullType(ApiErrorSeverityEnum),
      );
    }
    if (object.retryable != null) {
      yield r'retryable';
      yield serializers.serialize(
        object.retryable,
        specifiedType: const FullType(bool),
      );
    }
    if (object.requestId != null) {
      yield r'requestId';
      yield serializers.serialize(
        object.requestId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.operation != null) {
      yield r'operation';
      yield serializers.serialize(
        object.operation,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.stage != null) {
      yield r'stage';
      yield serializers.serialize(
        object.stage,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.details != null) {
      yield r'details';
      yield serializers.serialize(
        object.details,
        specifiedType: const FullType.nullable(BuiltList, [FullType(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ApiError object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ApiErrorBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'userMessage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userMessage = valueDes;
          break;
        case r'severity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiErrorSeverityEnum),
          ) as ApiErrorSeverityEnum;
          result.severity = valueDes;
          break;
        case r'retryable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.retryable = valueDes;
          break;
        case r'requestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.requestId = valueDes;
          break;
        case r'operation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.operation = valueDes;
          break;
        case r'stage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.stage = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(JsonObject)]),
          ) as BuiltList<JsonObject>?;
          if (valueDes == null) continue;
          result.details.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ApiError deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApiErrorBuilder();
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

class ApiErrorSeverityEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'info')
  static const ApiErrorSeverityEnum info = _$apiErrorSeverityEnum_info;
  @BuiltValueEnumConst(wireName: r'warning')
  static const ApiErrorSeverityEnum warning = _$apiErrorSeverityEnum_warning;
  @BuiltValueEnumConst(wireName: r'error')
  static const ApiErrorSeverityEnum error = _$apiErrorSeverityEnum_error;
  @BuiltValueEnumConst(wireName: r'critical')
  static const ApiErrorSeverityEnum critical = _$apiErrorSeverityEnum_critical;

  static Serializer<ApiErrorSeverityEnum> get serializer => _$apiErrorSeverityEnumSerializer;

  const ApiErrorSeverityEnum._(String name): super(name);

  static BuiltSet<ApiErrorSeverityEnum> get values => _$apiErrorSeverityEnumValues;
  static ApiErrorSeverityEnum valueOf(String name) => _$apiErrorSeverityEnumValueOf(name);
}

