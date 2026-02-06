//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'template_preview_response.g.dart';

/// TemplatePreviewResponse
///
/// Properties:
/// * [html] 
/// * [title] 
/// * [body] 
/// * [missingFields] 
/// * [metadata] 
@BuiltValue()
abstract class TemplatePreviewResponse implements Built<TemplatePreviewResponse, TemplatePreviewResponseBuilder> {
  @BuiltValueField(wireName: r'html')
  String get html;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'body')
  String get body;

  @BuiltValueField(wireName: r'missingFields')
  BuiltList<String> get missingFields;

  @BuiltValueField(wireName: r'metadata')
  BuiltMap<String, JsonObject?>? get metadata;

  TemplatePreviewResponse._();

  factory TemplatePreviewResponse([void updates(TemplatePreviewResponseBuilder b)]) = _$TemplatePreviewResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TemplatePreviewResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TemplatePreviewResponse> get serializer => _$TemplatePreviewResponseSerializer();
}

class _$TemplatePreviewResponseSerializer implements PrimitiveSerializer<TemplatePreviewResponse> {
  @override
  final Iterable<Type> types = const [TemplatePreviewResponse, _$TemplatePreviewResponse];

  @override
  final String wireName = r'TemplatePreviewResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TemplatePreviewResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'html';
    yield serializers.serialize(
      object.html,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
    yield r'missingFields';
    yield serializers.serialize(
      object.missingFields,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    if (object.metadata != null) {
      yield r'metadata';
      yield serializers.serialize(
        object.metadata,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TemplatePreviewResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TemplatePreviewResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'html':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.html = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.body = valueDes;
          break;
        case r'missingFields':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.missingFields.replace(valueDes);
          break;
        case r'metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.metadata.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TemplatePreviewResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TemplatePreviewResponseBuilder();
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

