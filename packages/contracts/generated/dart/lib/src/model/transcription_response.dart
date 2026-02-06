//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:survey_backend_api/src/model/transcription_segment.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transcription_response.g.dart';

/// TranscriptionResponse
///
/// Properties:
/// * [requestId] 
/// * [text] 
/// * [confidence] 
/// * [segments] 
/// * [processingTimeMs] 
/// * [provider] 
/// * [language] 
/// * [warnings] 
/// * [metadata] 
@BuiltValue()
abstract class TranscriptionResponse implements Built<TranscriptionResponse, TranscriptionResponseBuilder> {
  @BuiltValueField(wireName: r'requestId')
  String get requestId;

  @BuiltValueField(wireName: r'text')
  String get text;

  @BuiltValueField(wireName: r'confidence')
  double? get confidence;

  @BuiltValueField(wireName: r'segments')
  BuiltList<TranscriptionSegment>? get segments;

  @BuiltValueField(wireName: r'processingTimeMs')
  int get processingTimeMs;

  @BuiltValueField(wireName: r'provider')
  String get provider;

  @BuiltValueField(wireName: r'language')
  String get language;

  @BuiltValueField(wireName: r'warnings')
  BuiltList<String>? get warnings;

  @BuiltValueField(wireName: r'metadata')
  BuiltMap<String, JsonObject?>? get metadata;

  TranscriptionResponse._();

  factory TranscriptionResponse([void updates(TranscriptionResponseBuilder b)]) = _$TranscriptionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TranscriptionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TranscriptionResponse> get serializer => _$TranscriptionResponseSerializer();
}

class _$TranscriptionResponseSerializer implements PrimitiveSerializer<TranscriptionResponse> {
  @override
  final Iterable<Type> types = const [TranscriptionResponse, _$TranscriptionResponse];

  @override
  final String wireName = r'TranscriptionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TranscriptionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'requestId';
    yield serializers.serialize(
      object.requestId,
      specifiedType: const FullType(String),
    );
    yield r'text';
    yield serializers.serialize(
      object.text,
      specifiedType: const FullType(String),
    );
    if (object.confidence != null) {
      yield r'confidence';
      yield serializers.serialize(
        object.confidence,
        specifiedType: const FullType.nullable(double),
      );
    }
    if (object.segments != null) {
      yield r'segments';
      yield serializers.serialize(
        object.segments,
        specifiedType: const FullType(BuiltList, [FullType(TranscriptionSegment)]),
      );
    }
    yield r'processingTimeMs';
    yield serializers.serialize(
      object.processingTimeMs,
      specifiedType: const FullType(int),
    );
    yield r'provider';
    yield serializers.serialize(
      object.provider,
      specifiedType: const FullType(String),
    );
    yield r'language';
    yield serializers.serialize(
      object.language,
      specifiedType: const FullType(String),
    );
    if (object.warnings != null) {
      yield r'warnings';
      yield serializers.serialize(
        object.warnings,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
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
    TranscriptionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TranscriptionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'requestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestId = valueDes;
          break;
        case r'text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.text = valueDes;
          break;
        case r'confidence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(double),
          ) as double?;
          if (valueDes == null) continue;
          result.confidence = valueDes;
          break;
        case r'segments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TranscriptionSegment)]),
          ) as BuiltList<TranscriptionSegment>;
          result.segments.replace(valueDes);
          break;
        case r'processingTimeMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.processingTimeMs = valueDes;
          break;
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.provider = valueDes;
          break;
        case r'language':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.language = valueDes;
          break;
        case r'warnings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.warnings.replace(valueDes);
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
  TranscriptionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TranscriptionResponseBuilder();
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

