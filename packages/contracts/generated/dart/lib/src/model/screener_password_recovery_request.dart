//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'screener_password_recovery_request.g.dart';

/// ScreenerPasswordRecoveryRequest
///
/// Properties:
/// * [email] - Endereço de e-mail do Screener para recuperação de senha
@BuiltValue()
abstract class ScreenerPasswordRecoveryRequest implements Built<ScreenerPasswordRecoveryRequest, ScreenerPasswordRecoveryRequestBuilder> {
  /// Endereço de e-mail do Screener para recuperação de senha
  @BuiltValueField(wireName: r'email')
  String get email;

  ScreenerPasswordRecoveryRequest._();

  factory ScreenerPasswordRecoveryRequest([void updates(ScreenerPasswordRecoveryRequestBuilder b)]) = _$ScreenerPasswordRecoveryRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScreenerPasswordRecoveryRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScreenerPasswordRecoveryRequest> get serializer => _$ScreenerPasswordRecoveryRequestSerializer();
}

class _$ScreenerPasswordRecoveryRequestSerializer implements PrimitiveSerializer<ScreenerPasswordRecoveryRequest> {
  @override
  final Iterable<Type> types = const [ScreenerPasswordRecoveryRequest, _$ScreenerPasswordRecoveryRequest];

  @override
  final String wireName = r'ScreenerPasswordRecoveryRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScreenerPasswordRecoveryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ScreenerPasswordRecoveryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScreenerPasswordRecoveryRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ScreenerPasswordRecoveryRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScreenerPasswordRecoveryRequestBuilder();
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

