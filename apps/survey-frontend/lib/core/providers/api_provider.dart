import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:survey_backend_api/survey_backend_api.dart';

class ApiProvider extends ChangeNotifier {
  late SurveyBackendApi _api;

  SurveyBackendApi get api => _api;

  ApiProvider({String? baseUrl}) {
    _api = SurveyBackendApi(
      dio: Dio(BaseOptions(baseUrl: baseUrl ?? 'http://localhost:8000/api/v1')),
      serializers: standardSerializers,
    );
  }

  void setAuthToken(String token) {
    _api.dio.options.headers['Authorization'] = 'Bearer $token';
    notifyListeners();
  }

  void clearAuthToken() {
    _api.dio.options.headers.remove('Authorization');
    notifyListeners();
  }
}
