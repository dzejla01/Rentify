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
}
