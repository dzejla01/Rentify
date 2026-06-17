import 'dart:convert';
import 'package:rentify_desktop/config/api_config.dart';
import 'package:rentify_desktop/helper/http_helper.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/reservation.dart';
import 'package:rentify_desktop/models/user.dart';
import '../utils/session.dart';
import 'package:http/http.dart' as http;

import 'base_provider.dart';

class ReservationProvider extends BaseProvider<Reservation> {
  ReservationProvider() : super("Reservation");

  @override
  Reservation fromJson(dynamic data) {
    return Reservation.fromJson(data);
  }

  Future<List<String>> getAllowedActions(int id) async {
  final uri = Uri.parse(
    "${ApiConfig.apiBase}/api/Reservation/$id/allowed-actions",
  );

  final response = await http.get(
    uri,
    headers: HttpHelper.getHeaders(),
  );

  HttpHelper.checkResponse(response);

  final data = jsonDecode(response.body);

  if (data is List) {
    return data.map((e) => e.toString()).toList();
  }

  return [];
}

Future<Reservation> approve(int id) async {
  final uri = Uri.parse(
    "${ApiConfig.apiBase}/api/Reservation/$id/approve",
  );

  final response = await http.put(
    uri,
    headers: HttpHelper.getHeaders(),
  );

  HttpHelper.checkResponse(response);

  final data = jsonDecode(response.body);
  return fromJson(data);
}

Future<Reservation> finish(int id) async {
  final uri = Uri.parse(
    "${ApiConfig.apiBase}/api/Reservation/$id/finish",
  );

  final response = await http.put(
    uri,
    headers: HttpHelper.getHeaders(),
  );

  HttpHelper.checkResponse(response);

  final data = jsonDecode(response.body);
  return fromJson(data);
}

Future<Reservation> reject(int id, String reason) async {
  final uri = Uri.parse(
    "${ApiConfig.apiBase}/api/Reservation/$id/reject",
  );

  final response = await http.put(
    uri,
    headers: HttpHelper.getHeaders(),
    body: jsonEncode({"reason": reason}),
  );

  HttpHelper.checkResponse(response);

  final data = jsonDecode(response.body);
  return fromJson(data);
}

Future<Reservation> cancel(int id, String reason) async {
  final uri = Uri.parse(
    "${ApiConfig.apiBase}/api/Reservation/$id/cancel",
  );

  final response = await http.put(
    uri,
    headers: HttpHelper.getHeaders(),
    body: jsonEncode({"reason": reason}),
  );

  HttpHelper.checkResponse(response);

  final data = jsonDecode(response.body);
  return fromJson(data);
}
}