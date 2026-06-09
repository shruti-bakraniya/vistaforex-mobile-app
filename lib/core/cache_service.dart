import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  CacheService._();
  static final instance = CacheService._();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<void> setJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  Map<String, dynamic>? getJson(String key) {
    final s = _prefs.getString(key);
    if (s == null) return null;
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> setList(String key, List<dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  List<dynamic>? getList(String key) {
    final s = _prefs.getString(key);
    if (s == null) return null;
    try {
      return jsonDecode(s) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> clear() => _prefs.clear();
}
