//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'template_preview_request.g.dart';

/// TemplatePreviewRequest
///
/// Properties:
/// * [sampleData] 
@BuiltValue()
abstract class TemplatePreviewRequest implements Built<TemplatePreviewRequest, TemplatePreviewRequestBuilder> {
  @BuiltValueField(wireName: r'sampleData')
  BuiltMap<String, JsonObject?>? get sampleData;

  TemplatePreviewRequest._();

  factory TemplatePreviewRequest([void updates(TemplatePreviewRequestBuilder b)]) = _$TemplatePreviewRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TemplatePreviewRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TemplatePreviewRequest> get serializer => _$TemplatePreviewRequestSerializer();
}

class _$TemplatePreviewRequestSerializer implements PrimitiveSerializer<TemplatePreviewRequest> {
  @override
  final Iterable<Type> types = const [TemplatePreviewRequest, _$TemplatePreviewRequest];

  @override
  final String wireName = r'TemplatePreviewRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TemplatePreviewRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.sampleData != null) {
      yield r'sampleData';
      yield serializers.serialize(
        object.sampleData,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TemplatePreviewRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TemplatePreviewRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sampleData':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.sampleData.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TemplatePreviewRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TemplatePreviewRequestBuilder();
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

