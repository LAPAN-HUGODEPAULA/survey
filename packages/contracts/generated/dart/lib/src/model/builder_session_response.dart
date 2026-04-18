//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:survey_backend_api/src/model/screener_profile.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'builder_session_response.g.dart';

/// BuilderSessionResponse
///
/// Properties:
/// * [profile]
/// * [csrfToken]
@BuiltValue()
abstract class BuilderSessionResponse implements Built<BuilderSessionResponse, BuilderSessionResponseBuilder> {
  @BuiltValueField(wireName: r'profile')
  ScreenerProfile get profile;

  @BuiltValueField(wireName: r'csrfToken')
  String get csrfToken;

  BuilderSessionResponse._();

  factory BuilderSessionResponse([void updates(BuilderSessionResponseBuilder b)]) = _$BuilderSessionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BuilderSessionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BuilderSessionResponse> get serializer => _$BuilderSessionResponseSerializer();
}

class _$BuilderSessionResponseSerializer implements PrimitiveSerializer<BuilderSessionResponse> {
  @override
  final Iterable<Type> types = const [BuilderSessionResponse, _$BuilderSessionResponse];

  @override
  final String wireName = r'BuilderSessionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BuilderSessionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'profile';
    yield serializers.serialize(
      object.profile,
      specifiedType: const FullType(ScreenerProfile),
    );
    yield r'csrfToken';
    yield serializers.serialize(
      object.csrfToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BuilderSessionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BuilderSessionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'profile':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ScreenerProfile),
          ) as ScreenerProfile;
          result.profile.replace(valueDes);
          break;
        case r'csrfToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.csrfToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BuilderSessionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BuilderSessionResponseBuilder();
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
