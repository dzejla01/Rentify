import 'dart:convert';
import 'package:rentify_desktop/config/api_config.dart';
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

  Future<void> deleteAll(int id) async {
  final url = "${ApiConfig.apiBase}/api/Reservation/delete-all/$id";

  final response = await http.delete(
    Uri.parse(url),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Session.token}",
    },
  );

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception("Greška pri brisanju: ${response.body}");
  }
}
}