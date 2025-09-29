/// Generic service for loading form data from assets.
///
/// This service provides a generic approach to loading form data from JSON assets
/// with caching capabilities and error handling. It can be extended for specific
/// data types and used across the application.
library;

import 'package:survey_app/core/services/asset_list_provider.dart';

/// Abstract base class for form data services.
///
/// This class provides common functionality for loading form data from assets
/// including caching, error handling, and standardized method signatures.
abstract class FormDataService<T> {
  /// Cache for loaded data
  T? _cachedData;

  /// Loads data from assets.
  ///
  /// [forceReload] - Whether to bypass cache and reload from assets
  ///
  /// Returns the loaded data of type [T].
  /// Throws [Exception] if the data cannot be loaded.
  Future<T> loadData({bool forceReload = false}) async {
    if (_cachedData != null && !forceReload) {
      return _cachedData!;
    }

    try {
      final data = await loadFromAssets();
      _cachedData = data;
      return _cachedData!;
    } catch (e) {
      throw Exception('Failed to load ${getDataTypeName()}: $e');
    }
  }

  /// Loads data from assets. Must be implemented by subclasses.
  Future<T> loadFromAssets();

  /// Returns the name of the data type for error messages.
  String getDataTypeName();

  /// Clears cached data.
  void clearCache() {
    _cachedData = null;
  }

  /// Checks if data is cached.
  bool isCached() => _cachedData != null;
}

/// Service for loading string lists from JSON assets.
///
/// This service specializes in loading lists of strings from JSON files,
/// which is a common pattern for form dropdown options.
class StringListDataService extends FormDataService<List<String>> {
  final String assetPath;
  final String jsonKey;
  final String dataTypeName;

  /// Creates a new string list data service.
  ///
  /// [assetPath] - Path to the JSON asset file
  /// [jsonKey] - Key in the JSON object containing the string list
  /// [dataTypeName] - Human-readable name for error messages
  StringListDataService({
    required this.assetPath,
    required this.jsonKey,
    required this.dataTypeName,
  });

  @override
  Future<List<String>> loadFromAssets() async {
    final list = await AssetListProvider.loadStringList(assetPath, jsonKey);
    return List.unmodifiable(list);
  }

  @override
  String getDataTypeName() => dataTypeName;
}

/// Registry for managing multiple data services.
///
/// This class provides a centralized way to manage multiple data services
/// and perform bulk operations like loading all data or clearing all caches.
class FormDataServiceRegistry {
  final Map<String, FormDataService> _services = {};

  /// Registers a data service with a given key.
  void register<T>(String key, FormDataService<T> service) {
    _services[key] = service;
  }

  /// Gets a registered service by key.
  FormDataService<T>? getService<T>(String key) {
    return _services[key] as FormDataService<T>?;
  }

  /// Loads data for a specific service.
  Future<T> loadData<T>(String key, {bool forceReload = false}) async {
    final service = getService<T>(key);
    if (service == null) {
      throw Exception('Service with key "$key" not found');
    }
    return await service.loadData(forceReload: forceReload);
  }

  /// Loads data for all registered services.
  Future<Map<String, dynamic>> loadAllData({bool forceReload = false}) async {
    final Map<String, dynamic> results = {};

    for (final entry in _services.entries) {
      try {
        results[entry.key] = await entry.value.loadData(
          forceReload: forceReload,
        );
      } catch (e) {
        throw Exception('Failed to load data for "${entry.key}": $e');
      }
    }

    return results;
  }

  /// Clears cache for all registered services.
  void clearAllCaches() {
    for (final service in _services.values) {
      service.clearCache();
    }
  }

  /// Clears cache for a specific service.
  void clearCache(String key) {
    _services[key]?.clearCache();
  }

  /// Checks if all services have cached data.
  bool isAllDataCached() {
    return _services.values.every((service) => service.isCached());
  }

  /// Gets a list of all registered service keys.
  List<String> getRegisteredKeys() {
    return _services.keys.toList();
  }

  /// Removes a service from the registry.
  bool unregister(String key) {
    return _services.remove(key) != null;
  }

  /// Gets the number of registered services.
  int get serviceCount => _services.length;
}
