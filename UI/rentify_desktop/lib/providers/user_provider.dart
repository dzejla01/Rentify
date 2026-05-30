import 'dart:convert';
import 'package:rentify_desktop/config/api_config.dart';
import 'package:rentify_desktop/helper/http_helper.dart';
import 'package:rentify_desktop/models/user.dart';
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
      headers: HttpHelper.getHeaders(),
      body: jsonEncode({
        "email": email,
      }),
    );

    HttpHelper.checkResponse(response);

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
      headers: HttpHelper.getHeaders(),
      body: jsonEncode({
        "email": email,
        "code": code,
        "newPassword": newPassword,
      }),
    );

    HttpHelper.checkResponse(response);

    return true;
  }
}
