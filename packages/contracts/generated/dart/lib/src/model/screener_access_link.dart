//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'screener_access_link.g.dart';

/// ScreenerAccessLink
///
/// Properties:
/// * [token] 
/// * [screenerId] 
/// * [screenerName] 
/// * [surveyId] 
/// * [surveyDisplayName] 
/// * [createdAt] 
@BuiltValue()
abstract class ScreenerAccessLink implements Built<ScreenerAccessLink, ScreenerAccessLinkBuilder> {
  @BuiltValueField(wireName: r'token')
  String get token;

  @BuiltValueField(wireName: r'screenerId')
  String get screenerId;

  @BuiltValueField(wireName: r'screenerName')
  String get screenerName;

  @BuiltValueField(wireName: r'surveyId')
  String get surveyId;

  @BuiltValueField(wireName: r'surveyDisplayName')
  String get surveyDisplayName;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  ScreenerAccessLink._();

  factory ScreenerAccessLink([void updates(ScreenerAccessLinkBuilder b)]) = _$ScreenerAccessLink;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScreenerAccessLinkBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScreenerAccessLink> get serializer => _$ScreenerAccessLinkSerializer();
}

class _$ScreenerAccessLinkSerializer implements PrimitiveSerializer<ScreenerAccessLink> {
  @override
  final Iterable<Type> types = const [ScreenerAccessLink, _$ScreenerAccessLink];

  @override
  final String wireName = r'ScreenerAccessLink';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScreenerAccessLink object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
    yield r'screenerId';
    yield serializers.serialize(
      object.screenerId,
      specifiedType: const FullType(String),
    );
    yield r'screenerName';
    yield serializers.serialize(
      object.screenerName,
      specifiedType: const FullType(String),
    );
    yield r'surveyId';
    yield serializers.serialize(
      object.surveyId,
      specifiedType: const FullType(String),
    );
    yield r'surveyDisplayName';
    yield serializers.serialize(
      object.surveyDisplayName,
      specifiedType: const FullType(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ScreenerAccessLink object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScreenerAccessLinkBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        case r'screenerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.screenerId = valueDes;
          break;
        case r'screenerName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.screenerName = valueDes;
          break;
        case r'surveyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.surveyId = valueDes;
          break;
        case r'surveyDisplayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.surveyDisplayName = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ScreenerAccessLink deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScreenerAccessLinkBuilder();
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

