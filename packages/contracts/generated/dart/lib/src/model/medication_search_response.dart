//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:survey_backend_api/src/model/medication_search_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'medication_search_response.g.dart';

/// MedicationSearchResponse
///
/// Properties:
/// * [results] 
@BuiltValue()
abstract class MedicationSearchResponse implements Built<MedicationSearchResponse, MedicationSearchResponseBuilder> {
  @BuiltValueField(wireName: r'results')
  BuiltList<MedicationSearchItem> get results;

  MedicationSearchResponse._();

  factory MedicationSearchResponse([void updates(MedicationSearchResponseBuilder b)]) = _$MedicationSearchResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MedicationSearchResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MedicationSearchResponse> get serializer => _$MedicationSearchResponseSerializer();
}

class _$MedicationSearchResponseSerializer implements PrimitiveSerializer<MedicationSearchResponse> {
  @override
  final Iterable<Type> types = const [MedicationSearchResponse, _$MedicationSearchResponse];

  @override
  final String wireName = r'MedicationSearchResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MedicationSearchResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'results';
    yield serializers.serialize(
      object.results,
      specifiedType: const FullType(BuiltList, [FullType(MedicationSearchItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MedicationSearchResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MedicationSearchResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MedicationSearchItem)]),
          ) as BuiltList<MedicationSearchItem>;
          result.results.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MedicationSearchResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MedicationSearchResponseBuilder();
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

