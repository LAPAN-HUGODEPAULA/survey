//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transcription_request.g.dart';

/// TranscriptionRequest
///
/// Properties:
/// * [audioBase64] 
/// * [audioFormat] 
/// * [sampleRate] 
/// * [channels] 
/// * [durationSeconds] 
/// * [language] 
/// * [clinicalMode] 
/// * [confidenceThreshold] 
/// * [previewText] 
/// * [metadata] 
@BuiltValue()
abstract class TranscriptionRequest implements Built<TranscriptionRequest, TranscriptionRequestBuilder> {
  @BuiltValueField(wireName: r'audioBase64')
  String get audioBase64;

  @BuiltValueField(wireName: r'audioFormat')
  String get audioFormat;

  @BuiltValueField(wireName: r'sampleRate')
  int? get sampleRate;

  @BuiltValueField(wireName: r'channels')
  int? get channels;

  @BuiltValueField(wireName: r'durationSeconds')
  double? get durationSeconds;

  @BuiltValueField(wireName: r'language')
  String? get language;

  @BuiltValueField(wireName: r'clinicalMode')
  bool? get clinicalMode;

  @BuiltValueField(wireName: r'confidenceThreshold')
  double? get confidenceThreshold;

  @BuiltValueField(wireName: r'previewText')
  String? get previewText;

  @BuiltValueField(wireName: r'metadata')
  BuiltMap<String, JsonObject?>? get metadata;

  TranscriptionRequest._();

  factory TranscriptionRequest([void updates(TranscriptionRequestBuilder b)]) = _$TranscriptionRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TranscriptionRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TranscriptionRequest> get serializer => _$TranscriptionRequestSerializer();
}

class _$TranscriptionRequestSerializer implements PrimitiveSerializer<TranscriptionRequest> {
  @override
  final Iterable<Type> types = const [TranscriptionRequest, _$TranscriptionRequest];

  @override
  final String wireName = r'TranscriptionRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TranscriptionRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'audioBase64';
    yield serializers.serialize(
      object.audioBase64,
      specifiedType: const FullType(String),
    );
    yield r'audioFormat';
    yield serializers.serialize(
      object.audioFormat,
      specifiedType: const FullType(String),
    );
    if (object.sampleRate != null) {
      yield r'sampleRate';
      yield serializers.serialize(
        object.sampleRate,
        specifiedType: const FullType(int),
      );
    }
    if (object.channels != null) {
      yield r'channels';
      yield serializers.serialize(
        object.channels,
        specifiedType: const FullType(int),
      );
    }
    if (object.durationSeconds != null) {
      yield r'durationSeconds';
      yield serializers.serialize(
        object.durationSeconds,
        specifiedType: const FullType(double),
      );
    }
    if (object.language != null) {
      yield r'language';
      yield serializers.serialize(
        object.language,
        specifiedType: const FullType(String),
      );
    }
    if (object.clinicalMode != null) {
      yield r'clinicalMode';
      yield serializers.serialize(
        object.clinicalMode,
        specifiedType: const FullType(bool),
      );
    }
    if (object.confidenceThreshold != null) {
      yield r'confidenceThreshold';
      yield serializers.serialize(
        object.confidenceThreshold,
        specifiedType: const FullType(double),
      );
    }
    if (object.previewText != null) {
      yield r'previewText';
      yield serializers.serialize(
        object.previewText,
        specifiedType: const FullType(String),
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
    TranscriptionRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TranscriptionRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'audioBase64':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.audioBase64 = valueDes;
          break;
        case r'audioFormat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.audioFormat = valueDes;
          break;
        case r'sampleRate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sampleRate = valueDes;
          break;
        case r'channels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.channels = valueDes;
          break;
        case r'durationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.durationSeconds = valueDes;
          break;
        case r'language':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.language = valueDes;
          break;
        case r'clinicalMode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.clinicalMode = valueDes;
          break;
        case r'confidenceThreshold':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.confidenceThreshold = valueDes;
          break;
        case r'previewText':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.previewText = valueDes;
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
  TranscriptionRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TranscriptionRequestBuilder();
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

