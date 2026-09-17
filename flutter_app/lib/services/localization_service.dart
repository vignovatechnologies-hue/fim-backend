import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';

class LocalizationService {
  final ApiClient _apiClient;
  static const String _prefLangKey = 'user_preferred_language';
  static const String _prefDictKeyPrefix = 'cached_translations_';

  LocalizationService(this._apiClient);

  Future<List<Map<String, dynamic>>> fetchSupportedLanguages() async {
    try {
      final response = await _apiClient.get('/api/v1/languages');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print('[LocalizationService] ⚠️ Language list fetch error: $e');
    }
    // Hardcoded fallback list in case backend is offline
    return [
      {"code": "en", "name": "English", "nativeName": "English", "isDefault": true},
      {"code": "hi", "name": "Hindi", "nativeName": "हिन्दी", "isDefault": false},
      {"code": "te", "name": "Telugu", "nativeName": "తెలుగు", "isDefault": false},
    ];
  }

  Future<Map<String, String>> fetchTranslationDictionary(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_prefDictKeyPrefix$languageCode';

    try {
      final response = await _apiClient.get('/api/v1/translations?language=$languageCode');
      final data = response.data;
      if (data is Map && data.containsKey('translations')) {
        final Map<String, dynamic> rawDict = data['translations'];
        final Map<String, String> dict = rawDict.map((k, v) => MapEntry(k, v.toString()));

        // Cache locally for offline fast startup
        await prefs.setString(cacheKey, jsonEncode(dict));
        return dict;
      }
    } catch (e) {
      print('[LocalizationService] ⚠️ Translation dictionary fetch error for $languageCode: $e');
    }

    // Try reading cached dictionary from SharedPreferences
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final Map<String, dynamic> raw = jsonDecode(cached);
        return raw.map((k, v) => MapEntry(k, v.toString()));
      } catch (_) {}
    }

    return {};
  }

  Future<String> getSavedLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefLangKey) ?? 'en';
  }

  Future<void> saveLanguageCodeLocally(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLangKey, languageCode);
  }

  Future<void> syncLanguagePreferenceToBackend(String languageCode) async {
    try {
      final token = await _apiClient.dio.options.headers['Authorization'] ?? '';
      if (token.toString().isEmpty) {
        // User not logged in yet, skipping remote preference sync
        return;
      }
      await _apiClient.patch('/api/v1/users/me/preferences', data: {
        "preferredLanguage": languageCode,
      });
    } catch (_) {
      // Quietly ignore network/auth errors when offline or unauthenticated
    }
  }
}
