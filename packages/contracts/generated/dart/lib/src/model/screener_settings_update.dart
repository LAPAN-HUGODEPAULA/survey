//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'screener_settings_update.g.dart';

/// ScreenerSettingsUpdate
///
/// Properties:
/// * [defaultQuestionnaireId] 
@BuiltValue()
abstract class ScreenerSettingsUpdate implements Built<ScreenerSettingsUpdate, ScreenerSettingsUpdateBuilder> {
  @BuiltValueField(wireName: r'defaultQuestionnaireId')
  String get defaultQuestionnaireId;

  ScreenerSettingsUpdate._();

  factory ScreenerSettingsUpdate([void updates(ScreenerSettingsUpdateBuilder b)]) = _$ScreenerSettingsUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScreenerSettingsUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScreenerSettingsUpdate> get serializer => _$ScreenerSettingsUpdateSerializer();
}

class _$ScreenerSettingsUpdateSerializer implements PrimitiveSerializer<ScreenerSettingsUpdate> {
  @override
  final Iterable<Type> types = const [ScreenerSettingsUpdate, _$ScreenerSettingsUpdate];

  @override
  final String wireName = r'ScreenerSettingsUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScreenerSettingsUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'defaultQuestionnaireId';
    yield serializers.serialize(
      object.defaultQuestionnaireId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ScreenerSettingsUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScreenerSettingsUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'defaultQuestionnaireId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.defaultQuestionnaireId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ScreenerSettingsUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScreenerSettingsUpdateBuilder();
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

