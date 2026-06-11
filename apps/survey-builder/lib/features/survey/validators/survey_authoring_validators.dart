import 'package:design_system_flutter/widgets.dart';

class SurveyAuthoringValidators {
  const SurveyAuthoringValidators._();

  static String normalizeText(String? value) {
    return DsKeyFieldSupport.normalizeTextField(value ?? '');
  }

  static String normalizeKey(String? value) {
    return DsKeyFieldSupport.normalizeKeyField(value ?? '');
  }

  static String? required(String? value) {
    return DsKeyFieldSupport.validateRequired(value);
  }
}
