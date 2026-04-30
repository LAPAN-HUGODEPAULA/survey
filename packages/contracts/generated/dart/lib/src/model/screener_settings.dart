//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'screener_settings.g.dart';

/// ScreenerSettings
///
/// Properties:
/// * [defaultQuestionnaireId] 
/// * [defaultQuestionnaireName] 
@BuiltValue()
abstract class ScreenerSettings implements Built<ScreenerSettings, ScreenerSettingsBuilder> {
  @BuiltValueField(wireName: r'defaultQuestionnaireId')
  String? get defaultQuestionnaireId;

  @BuiltValueField(wireName: r'defaultQuestionnaireName')
  String? get defaultQuestionnaireName;

  ScreenerSettings._();

  factory ScreenerSettings([void updates(ScreenerSettingsBuilder b)]) = _$ScreenerSettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScreenerSettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScreenerSettings> get serializer => _$ScreenerSettingsSerializer();
}

class _$ScreenerSettingsSerializer implements PrimitiveSerializer<ScreenerSettings> {
  @override
  final Iterable<Type> types = const [ScreenerSettings, _$ScreenerSettings];

  @override
  final String wireName = r'ScreenerSettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScreenerSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.defaultQuestionnaireId != null) {
      yield r'defaultQuestionnaireId';
      yield serializers.serialize(
        object.defaultQuestionnaireId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.defaultQuestionnaireName != null) {
      yield r'defaultQuestionnaireName';
      yield serializers.serialize(
        object.defaultQuestionnaireName,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ScreenerSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScreenerSettingsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'defaultQuestionnaireId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.defaultQuestionnaireId = valueDes;
          break;
        case r'defaultQuestionnaireName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.defaultQuestionnaireName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ScreenerSettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScreenerSettingsBuilder();
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

