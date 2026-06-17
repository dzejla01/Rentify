import 'dart:convert';
import 'package:rentify_mobile/config/api_config.dart';
import 'package:rentify_mobile/helper/date_helper.dart';
import 'package:rentify_mobile/helper/http_helper.dart';
import 'package:rentify_mobile/models/reservation.dart';
import 'package:rentify_mobile/models/unavailable_dates.dart';
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

  Future<UnavailableDatesResponse> getUnavailableReservationDates({
  required int propertyId,
  DateTime? from,
  DateTime? to,
}) async {
  final queryParams = <String, String>{
    "propertyId": propertyId.toString(),
    if (from != null) "from": DateHelper.toDateOnly(from),
    if (to != null) "to": DateHelper.toDateOnly(to),
  };

  final uri = Uri.parse(
    "${ApiConfig.apiBase}/api/Reservation/unavailable-res-dates",
  ).replace(queryParameters: queryParams);

  final response = await http.get(
    uri,
    headers: HttpHelper.getHeaders(),
  );

  HttpHelper.checkResponse(response);

  final data = jsonDecode(response.body);
  return UnavailableDatesResponse.fromJson(data);
}

Future<UnavailableDatesResponse> getUnavailableMonthlyReservationMonths({
  required int propertyId,
  DateTime? from,
  DateTime? to,
}) async {
  final queryParams = <String, String>{
    "propertyId": propertyId.toString(),
    if (from != null) "from": DateHelper.toDateOnly(from),
    if (to != null) "to": DateHelper.toDateOnly(to),
  };

  final uri = Uri.parse(
    "${ApiConfig.apiBase}/api/Reservation/unavailable-res-months",
  ).replace(queryParameters: queryParams);

  final response = await http.get(
    uri,
    headers: HttpHelper.getHeaders(),
  );

  HttpHelper.checkResponse(response);

  final data = jsonDecode(response.body);
  return UnavailableDatesResponse.fromJson(data);
}
}
