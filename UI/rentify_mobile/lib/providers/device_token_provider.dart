import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:rentify_mobile/config/api_config.dart';
import 'package:rentify_mobile/utils/session.dart';

class DeviceTokenProvider extends ChangeNotifier {
  Future<void> registerFcmToken({String platform = "android"}) async {
    final jwt = Session.token;
    if (jwt == null || jwt.isEmpty) return;

    final fcm = await FirebaseMessaging.instance.getToken();
    if (fcm == null || fcm.isEmpty) return;

    Session.fcmToken = fcm;

    final url = Uri.parse("${ApiConfig.apiBase}/api/device-tokens/register");

    await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $jwt",
      },
      body: jsonEncode({
        "token": fcm,
        "platform": platform,
      }),
    );
  }

  Future<void> unregisterFcmToken() async {
    final jwt = Session.token;
    final fcm = Session.fcmToken;

    if (jwt == null || jwt.isEmpty) return;
    if (fcm == null || fcm.isEmpty) return;

    final url = Uri.parse("${ApiConfig.apiBase}/api/device-tokens/unregister");

    await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $jwt",
      },
      body: jsonEncode({"token": fcm}),
    );

    // lokalno očisti
    Session.fcmToken = null;
  }

  void listenForTokenRefresh({String platform = "android"}) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      Session.fcmToken = newToken;

      final jwt = Session.token;
      if (jwt == null || jwt.isEmpty) return;

      final url = Uri.parse("${ApiConfig.apiBase}/api/device-tokens/register");

      try {
        await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $jwt",
          },
          body: jsonEncode({
            "token": newToken,
            "platform": platform,
          }),
        );
      } catch (_) {}
    });
  }
}