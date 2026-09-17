import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'fim_auth_token';
  static const String _userKey = 'fim_auth_user';
  static const String _apiUrlKey = 'fim_api_url';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  StorageService(this._secureStorage, this._prefs);

  static Future<StorageService> init() async {
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    return StorageService(secureStorage, prefs);
  }

  // Token Management with dual persistence & safe fallbacks for Android/iOS updates
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (_) {}
    await _prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    try {
      final secureToken = await _secureStorage.read(key: _tokenKey);
      if (secureToken != null && secureToken.isNotEmpty) {
        return secureToken;
      }
    } catch (_) {}
    // Fallback to SharedPreferences if secure storage key reset on app update
    final prefsToken = _prefs.getString(_tokenKey);
    if (prefsToken != null && prefsToken.isNotEmpty) {
      try {
        await _secureStorage.write(key: _tokenKey, value: prefsToken);
      } catch (_) {}
    }
    return prefsToken;
  }

  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (_) {}
    await _prefs.remove(_tokenKey);
  }

  // User Profile Caching
  Future<void> saveUserData(String userJson) async {
    await _prefs.setString(_userKey, userJson);
  }

  String? getUserData() {
    return _prefs.getString(_userKey);
  }

  Future<void> clearUserData() async {
    await _prefs.remove(_userKey);
  }

  // Custom API URL Override (e.g. For physical device testing)
  Future<void> saveApiUrl(String url) async {
    await _prefs.setString(_apiUrlKey, url);
  }

  String? getApiUrl() {
    return _prefs.getString(_apiUrlKey);
  }

  // Remember Me / Password Save
  static const String _rememberMeKey = 'fim_remember_me';
  static const String _savedEmailKey = 'fim_saved_email';
  static const String _savedPasswordKey = 'fim_saved_password';

  Future<void> saveRememberedCredentials(bool rememberMe, String email, String password) async {
    await _prefs.setBool(_rememberMeKey, rememberMe);
    if (rememberMe) {
      await _prefs.setString(_savedEmailKey, email);
      try {
        await _secureStorage.write(key: _savedPasswordKey, value: password);
      } catch (_) {}
      await _prefs.setString(_savedPasswordKey, password);
    } else {
      await _prefs.remove(_savedEmailKey);
      await _prefs.remove(_savedPasswordKey);
      try {
        await _secureStorage.delete(key: _savedPasswordKey);
      } catch (_) {}
    }
  }

  bool isRememberMeEnabled() {
    return _prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<Map<String, String>> getRememberedCredentials() async {
    final email = _prefs.getString(_savedEmailKey) ?? '';
    String password = '';
    try {
      password = await _secureStorage.read(key: _savedPasswordKey) ?? '';
    } catch (_) {}
    if (password.isEmpty) {
      password = _prefs.getString(_savedPasswordKey) ?? '';
    }
    return {'email': email, 'password': password};
  }

  Future<void> clearAll() async {
    await clearToken();
    await clearUserData();
  }
}
