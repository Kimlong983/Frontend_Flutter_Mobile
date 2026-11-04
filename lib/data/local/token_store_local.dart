import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class TokenStoreLocal {
  TokenStoreLocal._();

  static final GetStorage _storage = GetStorage();

  static const String _accessTokenKey = "ACCESS_TOKEN";
  static const String _refreshTokenKey = "REFRESH_TOKEN";
  static const String _userKey = "USER_DATA";
  static const String _baseUrlKey = "CUSTOM_BASE_URL";

  /// Android emulator alias for the host machine's localhost.
  static const String defaultBaseUrl = "http://10.0.2.2:33033";

  static String getAccessToken() => _storage.read<String>(_accessTokenKey) ?? "";
  static void setAccessToken(String token) => _storage.write(_accessTokenKey, token);

  static String getRefreshToken() => _storage.read<String>(_refreshTokenKey) ?? "";
  static void setRefreshToken(String token) => _storage.write(_refreshTokenKey, token);

  static void setUser(Map<String, dynamic> user) => _storage.write(_userKey, jsonEncode(user));

  static Map<String, dynamic>? getUser() {
    final raw = _storage.read<String>(_userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static String getBaseUrl() {
    final custom = _storage.read<String>(_baseUrlKey)?.trim();
    return (custom == null || custom.isEmpty) ? defaultBaseUrl : custom;
  }

  static void setBaseUrl(String url) {
    var clean = url.trim();
    while (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    _storage.write(_baseUrlKey, clean);
  }

  static bool isLoggedIn() => getAccessToken().isNotEmpty;

  /// Removes tokens and the cached user (keeps the server URL).
  static void clear() {
    _storage.remove(_accessTokenKey);
    _storage.remove(_refreshTokenKey);
    _storage.remove(_userKey);
  }
}
