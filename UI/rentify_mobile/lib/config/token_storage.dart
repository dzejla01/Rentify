import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _key = "jwt";
  static const _storage = FlutterSecureStorage();
  static const _taggsKey = "user_taggs";

  static Future<void> save(String token) async {
    await _storage.write(key: _key, value: token);
  }

  static Future<String?> read() async {
    return _storage.read(key: _key);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _key);
  }

  // -----------------
  // TAGGS
  // -----------------
  static Future<void> saveTaggs(List<String> taggs) async {
    await _storage.write(key: _taggsKey, value: jsonEncode(taggs));
  }

  static Future<List<String>> readTaggs() async {
    final raw = await _storage.read(key: _taggsKey);
    if (raw == null || raw.trim().isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is List) return decoded.map((e) => e.toString()).toList();
    return [];
  }

  static Future<void> clearTaggs() async {
    await _storage.delete(key: _taggsKey);
  }
}