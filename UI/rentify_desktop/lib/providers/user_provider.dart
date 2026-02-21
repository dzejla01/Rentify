import 'dart:convert';
import 'package:rentify_desktop/config/api_config.dart';
import 'package:rentify_desktop/models/user.dart';
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
}