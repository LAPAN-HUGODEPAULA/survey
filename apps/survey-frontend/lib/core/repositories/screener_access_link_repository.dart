import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:survey_app/core/models/screener_access_link.dart';
import 'package:survey_app/core/services/api_config.dart';

class ScreenerAccessLinkRepository {
  ScreenerAccessLinkRepository({Dio? rawClient})
    : _rawClient = rawClient ?? ApiConfig.createDio();

  final Dio _rawClient;

  Future<ScreenerAccessLink> create({
    required String authToken,
    required String surveyId,
  }) async {
    final response = await _rawClient.post<Object?>(
      ApiConfig.requestPath('/screener_access_links/'),
      data: <String, dynamic>{'surveyId': surveyId},
      options: Options(
        headers: <String, dynamic>{'Authorization': 'Bearer $authToken'},
      ),
    );
    return ScreenerAccessLink.fromJson(_asMap(response.data));
  }

  Future<ScreenerAccessLink> resolve(String token) async {
    final response = await _rawClient.get<Object?>(
      ApiConfig.requestPath('/screener_access_links/$token'),
    );
    return ScreenerAccessLink.fromJson(_asMap(response.data));
  }

  String buildShareableUrl(String token) {
    return Uri.base.resolve('/access/$token').toString();
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    throw const FormatException('Unexpected response payload.');
  }
}
