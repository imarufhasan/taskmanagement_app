import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyThemeMode = 'app_theme_mode'; // 'light', 'dark', 'system'
  static const String _keyServerHost = 'app_custom_server_host';
  static const String _keyCachedUser = 'app_cached_user';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  String? getCustomServerHost() {
    return _prefs.getString(_keyServerHost);
  }

  Future<void> setCustomServerHost(String? host) async {
    if (host == null || host.trim().isEmpty) {
      await _prefs.remove(_keyServerHost);
    } else {
      await _prefs.setString(_keyServerHost, host.trim());
    }
  }

  Future<void> saveCachedUser(Map<String, dynamic> userMap) async {
    await _prefs.setString(_keyCachedUser, jsonEncode(userMap));
  }

  Map<String, dynamic>? getCachedUser() {
    final raw = _prefs.getString(_keyCachedUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCachedUser() async {
    await _prefs.remove(_keyCachedUser);
  }
}
