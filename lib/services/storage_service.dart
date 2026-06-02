import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyAccessToken = 'access_token';
  static const String keyCandidateId = 'candidate_id';
  static const String keyLanguageCode = 'language_code';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  String? getAccessToken() {
    return _prefs.getString(keyAccessToken);
  }

  Future<bool> saveAccessToken(String token) {
    return _prefs.setString(keyAccessToken, token);
  }

  int? getCandidateId() {
    return _prefs.getInt(keyCandidateId);
  }

  Future<bool> saveCandidateId(int id) {
    return _prefs.setInt(keyCandidateId, id);
  }

  String? getLanguageCode() {
    return _prefs.getString(keyLanguageCode);
  }

  Future<bool> saveLanguageCode(String code) {
    return _prefs.setString(keyLanguageCode, code);
  }

  Future<bool> clear() {
    return _prefs.clear();
  }
}
