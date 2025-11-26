/// Demographics data service for loading form-related data.
///
/// This service centralizes the loading of demographic form data including
/// diagnoses, education levels, and professions from asset files.
/// It provides caching capabilities and error handling.
library;

import 'package:survey_app/core/services/form_data_service.dart';

/// Service class for loading demographic form data from assets.
///
/// This service provides methods to load various demographic data sets
/// used in forms, with caching capabilities to avoid repeated asset loading.
/// Uses the generic FormDataServiceRegistry for efficient data management.
class DemographicsDataService {
  static DemographicsDataService? _instance;
  late final FormDataServiceRegistry _registry;

  /// Private constructor for singleton pattern
  DemographicsDataService._() {
    _initializeRegistry();
  }

  /// Singleton instance getter
  static DemographicsDataService get instance {
    _instance ??= DemographicsDataService._();
    return _instance!;
  }

  // Service keys for the registry
  static const String _diagnosesKey = 'diagnoses';
  static const String _educationLevelsKey = 'educationLevels';
  static const String _professionsKey = 'professions';

  /// Initializes the data service registry with all demographic data services.
  void _initializeRegistry() {
    _registry = FormDataServiceRegistry();

    // Register diagnoses service
    _registry.register(
      _diagnosesKey,
      StringListDataService(
        assetPath: 'assets/data/diagnoses.json',
        jsonKey: 'diagnoses',
        dataTypeName: 'diagnoses',
      ),
    );

    // Register education levels service
    _registry.register(
      _educationLevelsKey,
      StringListDataService(
        assetPath: 'assets/data/education_level.json',
        jsonKey: 'educationLevel',
        dataTypeName: 'education levels',
      ),
    );

    // Register professions service
    _registry.register(
      _professionsKey,
      StringListDataService(
        assetPath: 'assets/data/professions.json',
        jsonKey: 'professions',
        dataTypeName: 'professions',
      ),
    );
  }

  /// Loads the list of medical diagnoses from assets.
  ///
  /// Returns a list of available diagnoses for form selection.
  /// Uses caching to avoid repeated asset loading.
  ///
  /// Throws [Exception] if the asset cannot be loaded or parsed.
  Future<List<String>> loadDiagnoses({bool forceReload = false}) async {
    return await _registry.loadData<List<String>>(
      _diagnosesKey,
      forceReload: forceReload,
    );
  }

  /// Loads the list of education levels from assets.
  ///
  /// Returns a list of available education levels for form selection.
  /// Uses caching to avoid repeated asset loading.
  ///
  /// Throws [Exception] if the asset cannot be loaded or parsed.
  Future<List<String>> loadEducationLevels({bool forceReload = false}) async {
    return await _registry.loadData<List<String>>(
      _educationLevelsKey,
      forceReload: forceReload,
    );
  }

  /// Loads the list of professions from assets.
  ///
  /// Returns a list of available professions for form selection.
  /// Uses caching to avoid repeated asset loading.
  ///
  /// Throws [Exception] if the asset cannot be loaded or parsed.
  Future<List<String>> loadProfessions({bool forceReload = false}) async {
    return await _registry.loadData<List<String>>(
      _professionsKey,
      forceReload: forceReload,
    );
  }

  /// Loads all demographic data sets in parallel.
  ///
  /// Returns a [DemographicsData] object containing all loaded data.
  /// This method is useful when you need all demographic data at once.
  ///
  /// Uses caching to avoid repeated asset loading.
  /// Throws [Exception] if any asset cannot be loaded or parsed.
  Future<DemographicsData> loadAllData({bool forceReload = false}) async {
    try {
      final results = await Future.wait([
        loadDiagnoses(forceReload: forceReload),
        loadEducationLevels(forceReload: forceReload),
        loadProfessions(forceReload: forceReload),
      ]);

      return DemographicsData(
        diagnoses: results[0],
        educationLevels: results[1],
        professions: results[2],
      );
    } catch (e) {
      throw Exception('Failed to load demographics data: $e');
    }
  }

  /// Clears all cached data.
  ///
  /// Use this method when you want to force reload of all data
  /// on the next access.
  void clearCache() {
    _registry.clearAllCaches();
  }

  /// Clears cache for specific data type.
  void clearSpecificCache(String dataType) {
    switch (dataType.toLowerCase()) {
      case 'diagnoses':
        _registry.clearCache(_diagnosesKey);
        break;
      case 'education':
      case 'educationlevels':
        _registry.clearCache(_educationLevelsKey);
        break;
      case 'professions':
        _registry.clearCache(_professionsKey);
        break;
    }
  }

  /// Checks if specific data is cached.
  bool isDiagnosesCached() =>
      _registry.getService(_diagnosesKey)?.isCached() ?? false;
  bool isEducationLevelsCached() =>
      _registry.getService(_educationLevelsKey)?.isCached() ?? false;
  bool isProfessionsCached() =>
      _registry.getService(_professionsKey)?.isCached() ?? false;

  /// Checks if all data is cached.
  bool isAllDataCached() => _registry.isAllDataCached();
}

/// Data class containing all demographic form data.
///
/// This class holds all the loaded demographic data in a single object,
/// making it easy to pass around and access all data at once.
class DemographicsData {
  /// List of available medical diagnoses
  final List<String> diagnoses;

  /// List of available education levels
  final List<String> educationLevels;

  /// List of available professions
  final List<String> professions;

  /// Creates a new [DemographicsData] instance.
  const DemographicsData({
    required this.diagnoses,
    required this.educationLevels,
    required this.professions,
  });

  /// Creates a copy of this data with optional field updates.
  DemographicsData copyWith({
    List<String>? diagnoses,
    List<String>? educationLevels,
    List<String>? professions,
  }) {
    return DemographicsData(
      diagnoses: diagnoses ?? this.diagnoses,
      educationLevels: educationLevels ?? this.educationLevels,
      professions: professions ?? this.professions,
    );
  }

  @override
  String toString() {
    return 'DemographicsData(diagnoses: ${diagnoses.length} items, '
        'educationLevels: ${educationLevels.length} items, '
        'professions: ${professions.length} items)';
  }
}
