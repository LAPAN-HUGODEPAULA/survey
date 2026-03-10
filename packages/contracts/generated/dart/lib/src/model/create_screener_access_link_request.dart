//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_screener_access_link_request.g.dart';

/// CreateScreenerAccessLinkRequest
///
/// Properties:
/// * [surveyId] 
@BuiltValue()
abstract class CreateScreenerAccessLinkRequest implements Built<CreateScreenerAccessLinkRequest, CreateScreenerAccessLinkRequestBuilder> {
  @BuiltValueField(wireName: r'surveyId')
  String get surveyId;

  CreateScreenerAccessLinkRequest._();

  factory CreateScreenerAccessLinkRequest([void updates(CreateScreenerAccessLinkRequestBuilder b)]) = _$CreateScreenerAccessLinkRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateScreenerAccessLinkRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateScreenerAccessLinkRequest> get serializer => _$CreateScreenerAccessLinkRequestSerializer();
}

class _$CreateScreenerAccessLinkRequestSerializer implements PrimitiveSerializer<CreateScreenerAccessLinkRequest> {
  @override
  final Iterable<Type> types = const [CreateScreenerAccessLinkRequest, _$CreateScreenerAccessLinkRequest];

  @override
  final String wireName = r'CreateScreenerAccessLinkRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateScreenerAccessLinkRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'surveyId';
    yield serializers.serialize(
      object.surveyId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateScreenerAccessLinkRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateScreenerAccessLinkRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'surveyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.surveyId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateScreenerAccessLinkRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateScreenerAccessLinkRequestBuilder();
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

