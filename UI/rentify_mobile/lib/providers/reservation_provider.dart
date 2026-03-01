import 'dart:convert';
import 'package:rentify_mobile/config/api_config.dart';
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

  Future<UnavailableDatesResponse> getUnavailableDatesForReservations({
    required int propertyId,
    DateTime? from,
    DateTime? to,
  }) async {
    final queryParams = <String, String>{
      "propertyId": propertyId.toString(),
      if (from != null) "from": _toDateOnly(from),
      if (to != null) "to": _toDateOnly(to),
    };

    final uri = Uri.parse(
      "${ApiConfig.apiBase}/api/Reservation/unavailable-dates",
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        // ako koristiš JWT:
        if (Session.token != null) "Authorization": "Bearer ${Session.token}",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Greška pri učitavanju zauzetih datuma.");
    }

    final data = jsonDecode(response.body);
    return UnavailableDatesResponse.fromJson(data);
  }

  String _toDateOnly(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return "${x.year.toString().padLeft(4, '0')}-"
        "${x.month.toString().padLeft(2, '0')}-"
        "${x.day.toString().padLeft(2, '0')}";
  }
}
