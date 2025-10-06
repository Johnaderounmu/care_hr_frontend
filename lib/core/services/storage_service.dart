import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late Box _box;
  static late SharedPreferences _prefs;

  static const String _boxName = 'care_hr_app';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _box = await Hive.openBox(_boxName);
  }

  // SharedPreferences methods
  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  static Future<void> clear() async {
    await _prefs.clear();
  }

  // Hive methods
  static Future<void> put(String key, dynamic value) async {
    await _box.put(key, value);
  }

  static T? get<T>(String key) {
    return _box.get(key);
  }

  static Future<void> delete(String key) async {
    await _box.delete(key);
  }

  static Future<void> clearBox() async {
    await _box.clear();
  }

  // Convenience methods for common storage needs
  static Future<void> setUserToken(String token) async {
    await setString('user_token', token);
  }

  static String? getUserToken() {
    return getString('user_token');
  }

  static Future<void> setUserId(String userId) async {
    await setString('user_id', userId);
  }

  static String? getUserId() {
    return getString('user_id');
  }

  static Future<void> setUserRole(String role) async {
    await setString('user_role', role);
  }

  static String? getUserRole() {
    return getString('user_role');
  }

  static Future<void> setThemeMode(String mode) async {
    await setString('theme_mode', mode);
  }

  static String? getThemeMode() {
    return getString('theme_mode');
  }

  static Future<void> setLanguage(String language) async {
    await setString('language', language);
  }

  static String? getLanguage() {
    return getString('language');
  }

  static Future<void> setFirstLaunch(bool isFirst) async {
    await setBool('is_first_launch', isFirst);
  }

  static bool isFirstLaunch() {
    return getBool('is_first_launch') ?? true;
  }

  static Future<void> setNotificationSettings(
      Map<String, dynamic> settings) async {
    await put('notification_settings', settings);
  }

  static Map<String, dynamic>? getNotificationSettings() {
    return get<Map<String, dynamic>>('notification_settings');
  }

  // Auth-specific methods
  static Future<void> setToken(String token) async {
    await setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    return getString('auth_token');
  }

  static Future<void> clearToken() async {
    await remove('auth_token');
  }

  static Future<void> setUser(String userJson) async {
    await setString('auth_user', userJson);
  }

  static Future<String?> getUser() async {
    return getString('auth_user');
  }

  static Future<void> clearUser() async {
    await remove('auth_user');
  }
}
