import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';

  static TokenStorage? _instance;
  late SharedPreferences _prefs;

  TokenStorage._();

  static Future<TokenStorage> getInstance() async {
    if (_instance == null) {
      _instance = TokenStorage._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  String? getToken() => _prefs.getString(_tokenKey);

  Future<void> saveToken(String token) => _prefs.setString(_tokenKey, token);

  Future<void> saveUser({required String email, required String name}) async {
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setString(_userNameKey, name);
  }

  String? getUserEmail() => _prefs.getString(_userEmailKey);
  String? getUserName() => _prefs.getString(_userNameKey);

  Future<void> clear() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userNameKey);
  }

  bool get isLoggedIn => getToken() != null;
}
