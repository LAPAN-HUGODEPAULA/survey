import 'dart:convert';

import 'package:design_system_flutter/components/respondent_flow/respondent_flow_models.dart';
import 'package:flutter/services.dart';

class DsDemographicsAssetConfig {
  const DsDemographicsAssetConfig({
    this.diagnosesAssetPath = 'assets/data/diagnoses.json',
    this.diagnosesJsonKey = 'diagnoses',
    this.educationAssetPath = 'assets/data/education_level.json',
    this.educationJsonKey = 'educationLevel',
    this.professionsAssetPath = 'assets/data/professions.json',
    this.professionsJsonKey = 'professions',
  });

  final String diagnosesAssetPath;
  final String diagnosesJsonKey;
  final String educationAssetPath;
  final String educationJsonKey;
  final String professionsAssetPath;
  final String professionsJsonKey;
}

class DsDemographicsCatalogLoader {
  DsDemographicsCatalogLoader({
    AssetBundle? bundle,
    this.config = const DsDemographicsAssetConfig(),
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final DsDemographicsAssetConfig config;

  static final Map<String, List<String>> _cache = <String, List<String>>{};

  Future<DsDemographicsCatalogs> loadAll({bool forceReload = false}) async {
    final results = await Future.wait<List<String>>([
      _loadStringList(
        config.diagnosesAssetPath,
        config.diagnosesJsonKey,
        forceReload: forceReload,
      ),
      _loadStringList(
        config.educationAssetPath,
        config.educationJsonKey,
        forceReload: forceReload,
      ),
      _loadStringList(
        config.professionsAssetPath,
        config.professionsJsonKey,
        forceReload: forceReload,
      ),
    ]);

    return DsDemographicsCatalogs(
      diagnoses: results[0],
      educationLevels: results[1],
      professions: results[2],
    );
  }

  Future<List<String>> _loadStringList(
    String assetPath,
    String jsonKey, {
    required bool forceReload,
  }) async {
    final cacheKey = '$assetPath::$jsonKey';
    if (!forceReload && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final rawJson = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    final items = (decoded[jsonKey] as List<dynamic>? ?? const <dynamic>[])
        .map((dynamic item) => item.toString())
        .toList(growable: false);
    _cache[cacheKey] = items;
    return items;
  }
}
