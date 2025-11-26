library;

import 'package:patient_app/core/services/asset_loader.dart';

class AssetListProvider {
  static Future<List<String>> loadStringList(String path, String key) async {
    final map = await AssetLoader.loadJsonMap(path);
    final list = (map[key] as List?) ?? const [];
    return list.cast<String>();
  }
}
