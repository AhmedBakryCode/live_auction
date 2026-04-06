import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> saveUserData(String key, String value);
  Future<String?> getUserData(String key);
  Future<void> clearAll();
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> saveUserEmail(String email);
  Future<String?> getUserEmail();
  Future<void> saveUserName(String name);
  Future<String?> getUserName();
}

class LocalStorageServiceImpl implements LocalStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  @override
  Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> clearToken() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
  }

  @override
  Future<void> saveUserData(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  @override
  Future<String?> getUserData(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  // Helper methods for common user data
  Future<void> saveUserId(String userId) async {
    await saveUserData(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    return getUserData(_userIdKey);
  }

  Future<void> saveUserEmail(String email) async {
    await saveUserData(_userEmailKey, email);
  }

  Future<String?> getUserEmail() async {
    return getUserData(_userEmailKey);
  }

  Future<void> saveUserName(String name) async {
    await saveUserData(_userNameKey, name);
  }

  Future<String?> getUserName() async {
    return getUserData(_userNameKey);
  }
}
