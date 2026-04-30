//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'send_report_email_request.g.dart';

/// SendReportEmailRequest
///
/// Properties:
/// * [reportText] 
@BuiltValue()
abstract class SendReportEmailRequest implements Built<SendReportEmailRequest, SendReportEmailRequestBuilder> {
  @BuiltValueField(wireName: r'reportText')
  String? get reportText;

  SendReportEmailRequest._();

  factory SendReportEmailRequest([void updates(SendReportEmailRequestBuilder b)]) = _$SendReportEmailRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SendReportEmailRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SendReportEmailRequest> get serializer => _$SendReportEmailRequestSerializer();
}

class _$SendReportEmailRequestSerializer implements PrimitiveSerializer<SendReportEmailRequest> {
  @override
  final Iterable<Type> types = const [SendReportEmailRequest, _$SendReportEmailRequest];

  @override
  final String wireName = r'SendReportEmailRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SendReportEmailRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.reportText != null) {
      yield r'reportText';
      yield serializers.serialize(
        object.reportText,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SendReportEmailRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SendReportEmailRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reportText':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reportText = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SendReportEmailRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SendReportEmailRequestBuilder();
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

