import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyAccessToken = 'access_token';

  final SharedPreferences _prefs;

  StorageService(this._prefs);
  // String? getAccessToken() {
  //   return _prefs.getString(_keyAccessToken);
  // }
}
