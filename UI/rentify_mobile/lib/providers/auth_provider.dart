import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentify_mobile/config/api_config.dart';
import 'package:rentify_mobile/config/token_storage.dart';
import 'package:rentify_mobile/helper/http_helper.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../utils/session.dart';

class AuthProvider with ChangeNotifier {
  static String apiUrl = "${ApiConfig.apiBase}/api/User/login";

  String? _token;

  String? get token => _token;

  bool get isLoggedIn {
    if (_token == null) return false;
    return !JwtDecoder.isExpired(_token!);
  }

  Future<void> loadSession() async {
  _token = await TokenStorage.read();

  if (_token == null || _token!.isEmpty) {
    Session.token = null;
    Session.userId = null;
    Session.username = null;
    Session.fullName = null;
    Session.userImage = null;
    Session.fcmToken = null;
    Session.isLoggingFirstTime = null;
    Session.roles = [];
    notifyListeners();
    return;
  }

  await _fillSessionFromJwt(_token!);
  notifyListeners();
}

Future<void> _fillSessionFromJwt(String jwt) async {
  final payload = JwtDecoder.decode(jwt);

  final idRaw = payload['nameid'] ??
      payload['sub'] ??
      payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];

  final usernameRaw = payload['unique_name'] ??
      payload['name'] ??
      payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'];

  final roleRaw = payload['role'] ??
      payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

  final fullNameRaw = payload['fullName'] ??
      payload['fullname'] ??
      payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname'];

  final userImageRaw = payload['userImage'] ??
      payload['userimage'];

  final isLoggingFirstTimeRaw = payload['isLoggingFirstTime'] ??
      payload['isloggingfirsttime'];

  Session.token = jwt;
  Session.userId = int.tryParse(idRaw?.toString() ?? "");
  Session.username = usernameRaw?.toString();
  Session.fullName = fullNameRaw?.toString();
  Session.userImage = userImageRaw?.toString();

  if (isLoggingFirstTimeRaw != null) {
    if (isLoggingFirstTimeRaw is bool) {
      Session.isLoggingFirstTime = isLoggingFirstTimeRaw;
    } else {
      Session.isLoggingFirstTime =
          isLoggingFirstTimeRaw.toString().toLowerCase() == "true";
    }
  } else {
    Session.isLoggingFirstTime = null;
  }

  if (roleRaw is List) {
    Session.roles = roleRaw.map((e) => e.toString()).toList();
  } else if (roleRaw != null) {
    Session.roles = [roleRaw.toString()];
  } else {
    Session.roles = [];
  }

  Session.fcmToken = await TokenStorage.readFcmToken();
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
      headers: HttpHelper.getHeaders(withToken: false),
      body: jsonEncode(request.toJson()),
    );

    HttpHelper.checkResponse(response);

    final data = jsonDecode(response.body);
    final loginResp = LoginResponse.fromJson(data);

    final imaPristup = loginResp.roles.contains("Korisnik");
    if (!imaPristup) return "ZABRANJENO";

    Session.token = loginResp.token;
    Session.userId = loginResp.userId;
    Session.username = loginResp.userName;
    Session.fullName = loginResp.fullName;
    Session.userImage = loginResp.userImage;
    Session.roles = loginResp.roles;
    Session.isLoggingFirstTime = loginResp.isLoggingFirstTime;

    return "OK";
  }
}
