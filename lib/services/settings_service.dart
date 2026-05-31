import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService extends ChangeNotifier {
  final Box _box = Hive.box('settings');

  bool get isDark => _box.get('is_dark', defaultValue: true) as bool;
  bool get isKg => _box.get('is_kg', defaultValue: true) as bool;

  ThemeMode get themeMode => isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    await _box.put('is_dark', !isDark);
    notifyListeners();
  }

  Future<void> setWeightUnit(bool isKgValue) async {
    await _box.put('is_kg', isKgValue);
    notifyListeners();
  }
}
