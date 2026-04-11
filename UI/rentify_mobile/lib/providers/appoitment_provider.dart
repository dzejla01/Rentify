import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentify_mobile/config/api_config.dart';
import 'package:rentify_mobile/helper/date_helper.dart';
import 'package:rentify_mobile/helper/http_helper.dart';
import 'package:rentify_mobile/models/appointment.dart';
import 'package:rentify_mobile/models/unavailable_appointment_dates.dart';
import 'package:rentify_mobile/providers/base_provider.dart';


class AppoitmentProvider extends BaseProvider<Appointment> {
  AppoitmentProvider() : super("appointment");

  @override
  Appointment fromJson(dynamic data) {
    return Appointment.fromJson(data);
  }

  Future<UnavailableAppointmentsResponse> getUnavailableDates({
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
    "${ApiConfig.apiBase}/api/Appointment/unavailable-ap-dates",
  ).replace(queryParameters: queryParams);

  final response = await http.get(
    uri,
    headers: HttpHelper.getHeaders(),
  );

  HttpHelper.checkResponse(response);

  final data = jsonDecode(response.body);
  return UnavailableAppointmentsResponse.fromJson(data);
}
}




  