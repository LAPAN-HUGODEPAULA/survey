//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'medication_search_item.g.dart';

/// MedicationSearchItem
///
/// Properties:
/// * [substance] 
/// * [category] 
/// * [tradeNames] 
@BuiltValue()
abstract class MedicationSearchItem implements Built<MedicationSearchItem, MedicationSearchItemBuilder> {
  @BuiltValueField(wireName: r'substance')
  String get substance;

  @BuiltValueField(wireName: r'category')
  String get category;

  @BuiltValueField(wireName: r'trade_names')
  BuiltList<String> get tradeNames;

  MedicationSearchItem._();

  factory MedicationSearchItem([void updates(MedicationSearchItemBuilder b)]) = _$MedicationSearchItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MedicationSearchItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MedicationSearchItem> get serializer => _$MedicationSearchItemSerializer();
}

class _$MedicationSearchItemSerializer implements PrimitiveSerializer<MedicationSearchItem> {
  @override
  final Iterable<Type> types = const [MedicationSearchItem, _$MedicationSearchItem];

  @override
  final String wireName = r'MedicationSearchItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MedicationSearchItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'substance';
    yield serializers.serialize(
      object.substance,
      specifiedType: const FullType(String),
    );
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(String),
    );
    yield r'trade_names';
    yield serializers.serialize(
      object.tradeNames,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MedicationSearchItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MedicationSearchItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'substance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.substance = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.category = valueDes;
          break;
        case r'trade_names':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.tradeNames.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MedicationSearchItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MedicationSearchItemBuilder();
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

