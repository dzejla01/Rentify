import 'dart:convert';
import 'package:rentify_mobile/config/api_config.dart';
import 'package:rentify_mobile/models/user.dart';

import '../utils/session.dart';
import 'package:http/http.dart' as http;

import 'base_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
  User fromJson(dynamic data) {
    return User.fromJson(data);
  }

  Future<bool> forgotPassword(String email) async {
  final url = Uri.parse(
    "${ApiConfig.apiBase}/api/User/forgot-password",
  );

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "email": email,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Greška pri slanju reset emaila: ${response.body}",
    );
  }

  return true;
}

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final url = Uri.parse(
      "${ApiConfig.apiBase}/api/User/reset-password",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "code": code,
        "newPassword": newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Greska pri resetu lozinke: ${response.body}",
      );
    }

    return true;
  }
}
