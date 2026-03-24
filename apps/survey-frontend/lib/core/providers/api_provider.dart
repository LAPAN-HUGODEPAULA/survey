import 'package:flutter/material.dart';
import 'package:survey_app/core/services/api_config.dart';
import 'package:survey_backend_api/survey_backend_api.dart';

class ApiProvider extends ChangeNotifier {

  ApiProvider({String? baseUrl}) {
    final dio = ApiConfig.createDio();
    if (baseUrl != null) {
      dio.options.baseUrl = baseUrl;
    }
    _api = SurveyBackendApi(dio: dio, serializers: standardSerializers);
  }
  late SurveyBackendApi _api;

  SurveyBackendApi get api => _api;

  void setAuthToken(String token) {
    _api.dio.options.headers['Authorization'] = 'Bearer $token';
    notifyListeners();
  }

  void clearAuthToken() {
    _api.dio.options.headers.remove('Authorization');
    notifyListeners();
  }
}
