import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const String _boxName = 'local_cache';

  static Box get _box => Hive.box(_boxName);

  /// Stores a JSON-serializable map, list, or primitive type by key.
  static Future<void> put(String key, dynamic value) async {
    await _box.put(key, value);
  }

  /// Retrieves a value from cache synchronously. Returns null if not found or if reading errors.
  static dynamic get(String key) {
    try {
      if (_box.containsKey(key)) {
        return _box.get(key);
      }
    } catch (_) {}
    return null;
  }

  /// Deletes a key from the cache.
  static Future<void> delete(String key) async {
    await _box.delete(key);
  }

  /// Clears all entries in the local cache.
  static Future<void> clear() async {
    await _box.clear();
  }
}
