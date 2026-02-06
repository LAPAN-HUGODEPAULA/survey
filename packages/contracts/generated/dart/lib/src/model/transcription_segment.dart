//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transcription_segment.g.dart';

/// TranscriptionSegment
///
/// Properties:
/// * [startSeconds] 
/// * [endSeconds] 
/// * [text] 
/// * [confidence] 
@BuiltValue()
abstract class TranscriptionSegment implements Built<TranscriptionSegment, TranscriptionSegmentBuilder> {
  @BuiltValueField(wireName: r'startSeconds')
  double get startSeconds;

  @BuiltValueField(wireName: r'endSeconds')
  double get endSeconds;

  @BuiltValueField(wireName: r'text')
  String get text;

  @BuiltValueField(wireName: r'confidence')
  double? get confidence;

  TranscriptionSegment._();

  factory TranscriptionSegment([void updates(TranscriptionSegmentBuilder b)]) = _$TranscriptionSegment;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TranscriptionSegmentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TranscriptionSegment> get serializer => _$TranscriptionSegmentSerializer();
}

class _$TranscriptionSegmentSerializer implements PrimitiveSerializer<TranscriptionSegment> {
  @override
  final Iterable<Type> types = const [TranscriptionSegment, _$TranscriptionSegment];

  @override
  final String wireName = r'TranscriptionSegment';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TranscriptionSegment object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'startSeconds';
    yield serializers.serialize(
      object.startSeconds,
      specifiedType: const FullType(double),
    );
    yield r'endSeconds';
    yield serializers.serialize(
      object.endSeconds,
      specifiedType: const FullType(double),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    TranscriptionSegment object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TranscriptionSegmentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'startSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.startSeconds = valueDes;
          break;
        case r'endSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.endSeconds = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TranscriptionSegment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TranscriptionSegmentBuilder();
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

