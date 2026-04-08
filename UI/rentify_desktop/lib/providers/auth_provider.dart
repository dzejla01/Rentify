import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rentify_desktop/helper/http_helper.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';
import '../utils/session.dart';

class AuthProvider with ChangeNotifier {
  static const String apiUrl = "http://localhost:5103/api/User/login";

  Future<String> prijava(LoginRequest request) async {
    final url = Uri.parse(apiUrl);

    final response = await http.post(
      url,
      headers: HttpHelper.getHeaders(),
      body: jsonEncode(request.toJson()),
    );

    HttpHelper.checkResponse(response);

    final data = jsonDecode(response.body);
    final loginResp = LoginResponse.fromJson(data);

    final imaPristup = loginResp.roles.contains("Vlasnik");
    if (!imaPristup) return "ZABRANJENO";
    Session.token = loginResp.token;
    Session.userId = loginResp.userId;
    Session.username = loginResp.userName;
    Session.roles = loginResp.roles;
    return "OK";
  }
}
