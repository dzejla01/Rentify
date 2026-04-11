import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentify_desktop/config/api_config.dart';
import 'package:rentify_desktop/helper/http_helper.dart';
import 'package:rentify_desktop/models/appointment.dart';
import 'package:rentify_desktop/providers/base_provider.dart';

class AppoitmentProvider extends BaseProvider<Appointment> {
  AppoitmentProvider() : super("appointment");

  @override
  Appointment fromJson(dynamic data) {
    return Appointment.fromJson(data);
  }

  Future<List<String>> getAllowedActions(int id) async {
    final uri = Uri.parse(
      "${ApiConfig.apiBase}/api/Appointment/$id/allowed-actions",
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

  Future<Appointment> approve(int id) async {
    final uri = Uri.parse(
      "${ApiConfig.apiBase}/api/Appointment/$id/approve",
    );

    final response = await http.put(
      uri,
      headers: HttpHelper.getHeaders(),
    );

    HttpHelper.checkResponse(response);

    final data = jsonDecode(response.body);
    return fromJson(data);
  }

  Future<Appointment> reject(int id) async {
    final uri = Uri.parse(
      "${ApiConfig.apiBase}/api/Appointment/$id/reject",
    );

    final response = await http.put(
      uri,
      headers: HttpHelper.getHeaders(),
    );

    HttpHelper.checkResponse(response);

    final data = jsonDecode(response.body);
    return fromJson(data);
  }

  Future<Appointment> cancel(int id) async {
    final uri = Uri.parse(
      "${ApiConfig.apiBase}/api/Appointment/$id/cancel",
    );

    final response = await http.put(
      uri,
      headers: HttpHelper.getHeaders(),
    );

    HttpHelper.checkResponse(response);

    final data = jsonDecode(response.body);
    return fromJson(data);
  }

  Future<Appointment> finish(int id) async {
    final uri = Uri.parse(
      "${ApiConfig.apiBase}/api/Appointment/$id/finish",
    );

    final response = await http.put(
      uri,
      headers: HttpHelper.getHeaders(),
    );

    HttpHelper.checkResponse(response);

    final data = jsonDecode(response.body);
    return fromJson(data);
  }

}




  