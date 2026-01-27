//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'screener_login.g.dart';

/// ScreenerLogin
///
/// Properties:
/// * [email] - Endereço de e-mail do Screener
/// * [password] - Senha do Screener
@BuiltValue()
abstract class ScreenerLogin implements Built<ScreenerLogin, ScreenerLoginBuilder> {
  /// Endereço de e-mail do Screener
  @BuiltValueField(wireName: r'email')
  String get email;

  /// Senha do Screener
  @BuiltValueField(wireName: r'password')
  String get password;

  ScreenerLogin._();

  factory ScreenerLogin([void updates(ScreenerLoginBuilder b)]) = _$ScreenerLogin;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScreenerLoginBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScreenerLogin> get serializer => _$ScreenerLoginSerializer();
}

class _$ScreenerLoginSerializer implements PrimitiveSerializer<ScreenerLogin> {
  @override
  final Iterable<Type> types = const [ScreenerLogin, _$ScreenerLogin];

  @override
  final String wireName = r'ScreenerLogin';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScreenerLogin object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ScreenerLogin object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScreenerLoginBuilder result,
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
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ScreenerLogin deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScreenerLoginBuilder();
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

