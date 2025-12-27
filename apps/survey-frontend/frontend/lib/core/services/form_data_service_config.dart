/// Configuration for form data services across the application.
///
/// This file centralizes the configuration of data services used throughout
/// the application, making it easy to manage asset paths, service registrations,
/// and providing convenient access to commonly used data services.
library;

import 'package:flutter/foundation.dart';
import 'package:survey_app/core/services/form_data_service.dart';
import 'package:survey_app/core/services/demographics_data_service.dart';

/// Global configuration for form data services.
///
/// This class provides static methods and constants to configure and access
/// data services used across the application.
class FormDataServiceConfig {
  /// Private constructor to prevent instantiation
  FormDataServiceConfig._();

  // Asset paths for commonly used data files
  static const String diagnosesAssetPath = 'assets/data/diagnoses.json';
  static const String educationLevelsAssetPath =
      'assets/data/education_level.json';
  static const String professionsAssetPath = 'assets/data/professions.json';

  // JSON keys for data extraction
  static const String diagnosesJsonKey = 'diagnoses';
  static const String educationLevelsJsonKey = 'educationLevel';
  static const String professionsJsonKey = 'professions';

  /// Creates a global form data service registry with all common services.
  ///
  /// This method can be used to initialize a registry with all the commonly
  /// used data services in the application.
  static FormDataServiceRegistry createGlobalRegistry() {
    final registry = FormDataServiceRegistry();

    // Register standard demographic data services
    registry.register(
      'global_diagnoses',
      StringListDataService(
        assetPath: diagnosesAssetPath,
        jsonKey: diagnosesJsonKey,
        dataTypeName: 'diagnoses',
      ),
    );

    registry.register(
      'global_education_levels',
      StringListDataService(
        assetPath: educationLevelsAssetPath,
        jsonKey: educationLevelsJsonKey,
        dataTypeName: 'education levels',
      ),
    );

    registry.register(
      'global_professions',
      StringListDataService(
        assetPath: professionsAssetPath,
        jsonKey: professionsJsonKey,
        dataTypeName: 'professions',
      ),
    );

    return registry;
  }

  /// Gets the demographics data service instance.
  ///
  /// This is a convenience method to access the singleton demographics
  /// data service from anywhere in the application.
  static DemographicsDataService get demographicsService =>
      DemographicsDataService.instance;

  /// Creates a custom string list data service for any asset.
  ///
  /// This method provides a convenient way to create data services for
  /// custom JSON assets that follow the standard string list format.
  ///
  /// [assetPath] - Path to the JSON asset file
  /// [jsonKey] - Key in the JSON object containing the string list
  /// [dataTypeName] - Human-readable name for error messages
  static StringListDataService createCustomStringListService({
    required String assetPath,
    required String jsonKey,
    required String dataTypeName,
  }) {
    return StringListDataService(
      assetPath: assetPath,
      jsonKey: jsonKey,
      dataTypeName: dataTypeName,
    );
  }

  /// Validates that required asset files exist in the expected format.
  ///
  /// This method can be used during application initialization to verify
  /// that all required data files are present and properly formatted.
  ///
  /// Returns a list of missing or invalid asset paths.
  static Future<List<String>> validateAssets() async {
    final List<String> invalidAssets = [];
    final registry = createGlobalRegistry();

    for (final serviceKey in registry.getRegisteredKeys()) {
      try {
        await registry.loadData(serviceKey);
      } catch (e) {
        invalidAssets.add('$serviceKey: $e');
      }
    }

    return invalidAssets;
  }

  /// Preloads all standard demographic data.
  ///
  /// This method can be called during application startup to preload
  /// all commonly used demographic data, improving performance for
  /// subsequent form loads.
  static Future<void> preloadDemographicData() async {
    try {
      await DemographicsDataService.instance.loadAllData();
    } catch (e) {
      // Log error but don't throw to avoid disrupting app initialization
    }
  }

  /// Clears all cached data across all services.
  ///
  /// This method can be used when you want to force a complete reload
  /// of all data, for example after updating asset files.
  static void clearAllCaches() {
    DemographicsDataService.instance.clearCache();
    // Add other service cache clearing here as needed
  }
}
