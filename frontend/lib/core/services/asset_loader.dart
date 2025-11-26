library;

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AssetLoader {
  static Future<String> loadString(String path) {
    return rootBundle.loadString(path);
  }

  static Future<Map<String, dynamic>> loadJsonMap(String path) async {
    final raw = await loadString(path);
    return json.decode(raw) as Map<String, dynamic>;
  }

  static Future<T> loadAndParse<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final map = await loadJsonMap(path);
    return fromJson(map);
  }
}
