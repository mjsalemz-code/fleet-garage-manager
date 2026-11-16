import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class LocalDataStore {
  static const String _storageKey = 'fleet_garage_manager_data';

  Future<AppData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return AppData();
    }

    try {
      final decoded = jsonDecode(raw);
      return AppData.fromMap(decoded as Map<String, dynamic>);
    } catch (_) {
      return AppData();
    }
  }

  Future<void> save(AppData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(data.toMap()));
  }

  Future<String> exportJson(AppData data) async {
    return jsonEncode(data.toMap());
  }

  Future<void> importJson(String jsonString) async {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup JSON');
    }
    final data = AppData.fromMap(decoded);
    await save(data);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
