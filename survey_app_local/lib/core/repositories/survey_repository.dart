library;

import 'package:survey_app/core/models/survey/survey.dart';
import 'package:survey_app/core/services/asset_loader.dart';

class SurveyRepository {
  Future<Survey> getByPath(String path) {
    return AssetLoader.loadAndParse(path, (m) => Survey.fromJson(m));
  }

  Future<Map<String, dynamic>> getRawByPath(String path) {
    return AssetLoader.loadJsonMap(path);
  }
}
