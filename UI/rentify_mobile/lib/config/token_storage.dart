import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _key = "jwt";
  static const _storage = FlutterSecureStorage();
  // static const _taggsKey = "user_taggs";
  static const _fcmKey = "fcm_token";

  static Future<void> saveFcmToken(String token) async {
    await _storage.write(key: _fcmKey, value: token);
  }
  
  static Future<String?> readFcmToken() async {
    return await _storage.read(key: _fcmKey);
  }
  
  static Future<void> clearFcmToken() async {
    await _storage.delete(key: _fcmKey);
  }

  static Future<void> save(String token) async {
    await _storage.write(key: _key, value: token);
  }

  static Future<String?> read() async {
    return _storage.read(key: _key);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}