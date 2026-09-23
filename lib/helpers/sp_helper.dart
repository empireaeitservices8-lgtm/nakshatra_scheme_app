import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/sp_keys.dart' as sp_keys;

class SpHelper {
  static SharedPreferences? _sp;
  static FlutterSecureStorage? _ss;

  static Future<SharedPreferences> getSP() async {
    _sp ??= await SharedPreferences.getInstance();
    await _sp!.reload();
    return _sp!;
  }

  static FlutterSecureStorage _secureInstance() {
    _ss ??= const FlutterSecureStorage();
    return _ss!;
  }

  /// Save string in shared pref
  static Future<bool> saveString(String key, String value,
      {bool secure = false}) async {
    if (secure) {
      await _secureInstance().write(key: key, value: value);
      return true;
    }
    final sp = await getSP();
    return await sp.setString(key, value);
  }

  /// Read saved String
  static Future<String?> getString(String key, {bool secure = false}) async {
    if (secure) {
      return await _secureInstance().read(key: key);
    }
    final sp = await getSP();
    return sp.getString(key);
  }

  /// Save integer
  static Future<bool> saveInt(String key, int value) async {
    final sp = await getSP();
    return await sp.setInt(key, value);
  }

  /// Read saved integer
  static Future<int?> getInt(String key) async {
    final sp = await getSP();
    return sp.getInt(key);
  }

  /// Save boolean
  static Future<bool> saveBoolean(String key, bool value) async {
    final sp = await getSP();
    return await sp.setBool(key, value);
  }

  /// Read saved boolean
  static Future<bool?> getBoolean(String key) async {
    final sp = await getSP();
    return sp.getBool(key);
  }

  /// Clears all preferences
  static Future<bool?> clearAll() async {
    final sp = await getSP();
    return await sp.clear();
  }

  // =========================================================
  // User Session Management
  // =========================================================

  /// Persists full user session details to SharedPreferences
  static Future<void> saveUserSession({
    required String sessionId,
    int? userId,
    String? name,
    String? email,
    String? phone,
    int? partnerId,
    String? city,
  }) async {
    await saveString(sp_keys.keyToken, sessionId);
    await saveBoolean(sp_keys.keyIsLoggedIn, true);

    if (userId != null) {
      await saveInt(sp_keys.keyUserId, userId);
    }
    if (name != null && name.isNotEmpty) {
      await saveString(sp_keys.keyUserName, name);
    }
    if (email != null && email.isNotEmpty) {
      await saveString(sp_keys.keyEmail, email);
    }
    if (phone != null && phone.isNotEmpty) {
      await saveString(sp_keys.keyUseMobile, phone);
    }
    if (partnerId != null) {
      await saveInt(sp_keys.keyPartnerId, partnerId);
    }
    if (city != null && city.isNotEmpty) {
      await saveString(sp_keys.keyCity, city);
    }
  }

  /// Returns current active session ID (Token)
  static Future<String?> getSessionId() async {
    return await getString(sp_keys.keyToken);
  }

  /// Returns whether user is currently logged in
  static Future<bool> isLoggedIn() async {
    final token = await getSessionId();
    return token != null && token.isNotEmpty;
  }

  /// Returns user's display name
  static Future<String?> getUserName() async {
    return await getString(sp_keys.keyUserName);
  }

  /// Returns user's email
  static Future<String?> getUserEmail() async {
    return await getString(sp_keys.keyEmail);
  }

  /// Returns user's phone
  static Future<String?> getUserPhone() async {
    return await getString(sp_keys.keyUseMobile);
  }

  /// Returns user's ID
  static Future<int?> getUserId() async {
    return await getInt(sp_keys.keyUserId);
  }

  /// Returns partner ID
  static Future<int?> getPartnerId() async {
    return await getInt(sp_keys.keyPartnerId);
  }

  /// Returns user's city
  static Future<String?> getCity() async {
    return await getString(sp_keys.keyCity);
  }

  /// Clears user session on logout
  static Future<void> clearUserSession() async {
    final sp = await getSP();
    await sp.remove(sp_keys.keyToken);
    await sp.remove(sp_keys.keyIsLoggedIn);
    await sp.remove(sp_keys.keyUserId);
    await sp.remove(sp_keys.keyUserName);
    await sp.remove(sp_keys.keyEmail);
    await sp.remove(sp_keys.keyUseMobile);
    await sp.remove(sp_keys.keyPartnerId);
    await sp.remove(sp_keys.keyCity);
  }
}

extension RememberBool on bool {
  Future rememberMe(String name) async {
    await SpHelper.saveBoolean(name, this);
  }

  Future<bool> getMeBack(String name) async {
    return await SpHelper.getBoolean(name) ?? this;
  }
}

extension RememberString on String {
  rememberMe(String name) async {
    await SpHelper.saveString(name, this);
  }

  Future<String> getMeBack(String name) async {
    return await SpHelper.getString(name) ?? this;
  }
}
