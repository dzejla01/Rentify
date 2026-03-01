import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentify_mobile/config/token_storage.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';
import '../utils/session.dart';

class AuthProvider with ChangeNotifier {
  static const String apiUrl = "http://192.168.2.23:5103/api/User/login";

  String? _token;

  String? get token => _token;

  bool get isLoggedIn {
    if (_token == null) return false;
    return !JwtDecoder.isExpired(_token!);
  }

  Future<void> loadSession() async {
    _token = await TokenStorage.read();

    Session.taggs = await TokenStorage.readTaggs();

    if (!isLoggedIn) {
      notifyListeners();
      return;
    }

    _fillSessionFromJwt(_token!);
    notifyListeners();
  }

  void _fillSessionFromJwt(String jwt) {
    final payload = JwtDecoder.decode(jwt);

    final idRaw = payload['nameid'] ??
        payload['sub'] ??
        payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];

    final usernameRaw = payload['unique_name'] ??
        payload['name'] ??
        payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'];

    final roleRaw = payload['role'] ??
        payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

    Session.token = jwt;
    Session.userId = int.tryParse(idRaw?.toString() ?? "");
    Session.username = usernameRaw?.toString();

    if (roleRaw is List) {
      Session.roles = roleRaw.map((e) => e.toString()).toList();
    } else if (roleRaw != null) {
      Session.roles = [roleRaw.toString()];
    } else {
      Session.roles = [];
    }
  }

  Future<void> setToken(String token) async {
    _token = token;
    await TokenStorage.save(token);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    await TokenStorage.clear();
    notifyListeners();
  }

  Future<String> prijava(LoginRequest request) async {
    final url = Uri.parse(apiUrl);

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final loginResp = LoginResponse.fromJson(data);

      final imaPristup = loginResp.roles.contains("Korisnik");
      if (!imaPristup) return "ZABRANJENO";

      Session.token = loginResp.token;
      Session.userId = loginResp.userId;
      Session.username = loginResp.userName;
      Session.roles = loginResp.roles;
      Session.isLoggingFirstTime = loginResp.isLoggingFirstTime;

      return loginResp.token;
    }

    if (response.statusCode == 401) return "NEISPRAVNO";
    if (response.statusCode == 403) return "ZABRANJENO";

    return "GRESKA";
  }
}
