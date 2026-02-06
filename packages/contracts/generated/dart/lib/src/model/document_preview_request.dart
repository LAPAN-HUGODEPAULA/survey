//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'document_preview_request.g.dart';

/// DocumentPreviewRequest
///
/// Properties:
/// * [sessionId] 
/// * [documentType] 
/// * [title] 
/// * [body] 
@BuiltValue()
abstract class DocumentPreviewRequest implements Built<DocumentPreviewRequest, DocumentPreviewRequestBuilder> {
  @BuiltValueField(wireName: r'sessionId')
  String get sessionId;

  @BuiltValueField(wireName: r'documentType')
  String get documentType;

  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'body')
  String? get body;

  DocumentPreviewRequest._();

  factory DocumentPreviewRequest([void updates(DocumentPreviewRequestBuilder b)]) = _$DocumentPreviewRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DocumentPreviewRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DocumentPreviewRequest> get serializer => _$DocumentPreviewRequestSerializer();
}

class _$DocumentPreviewRequestSerializer implements PrimitiveSerializer<DocumentPreviewRequest> {
  @override
  final Iterable<Type> types = const [DocumentPreviewRequest, _$DocumentPreviewRequest];

  @override
  final String wireName = r'DocumentPreviewRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DocumentPreviewRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sessionId';
    yield serializers.serialize(
      object.sessionId,
      specifiedType: const FullType(String),
    );
    yield r'documentType';
    yield serializers.serialize(
      object.documentType,
      specifiedType: const FullType(String),
    );
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.body != null) {
      yield r'body';
      yield serializers.serialize(
        object.body,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DocumentPreviewRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DocumentPreviewRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sessionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sessionId = valueDes;
          break;
        case r'documentType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.documentType = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DocumentPreviewRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DocumentPreviewRequestBuilder();
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

