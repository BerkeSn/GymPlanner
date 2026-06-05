import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._();

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  // Token Kaydet
  static Future<void> saveToken(
    String token,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Token Oku
  static Future<String?> getToken() async {
    final prefs =
        await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Token Sil (Çıkış yapınca)
  static Future<void> deleteToken() async {
    final prefs =
        await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // UserId Kaydet
  static Future<void> saveUserId(
    String userId,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();
    await prefs.setString(
      _userIdKey,
      userId.toString(),
    );
  }

  // UserId Oku
  static Future<String?> getUserId() async {
    final prefs =
        await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Tüm Verileri Sil (Çıkış yapınca)
  static Future<void> clearAll() async {
    final prefs =
        await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  // Kullanıcı giriş yapmış mı?
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
