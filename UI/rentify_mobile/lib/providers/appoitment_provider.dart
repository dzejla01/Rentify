import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentify_mobile/config/api_config.dart';
import 'package:rentify_mobile/models/appointment.dart';
import 'package:rentify_mobile/models/unavailable_appointment_dates.dart';
import 'package:rentify_mobile/models/unavailable_dates.dart';
import 'package:rentify_mobile/providers/base_provider.dart';
import 'package:rentify_mobile/utils/session.dart';

class AppoitmentProvider extends BaseProvider<Appointment> {
  AppoitmentProvider() : super("appointment");

  @override
  Appointment fromJson(dynamic data) {
    return Appointment.fromJson(data);
  }


  Map<String, String> _headers() {
    return {
      "Content-Type": "application/json",
      if (Session.token != null)
        "Authorization": "Bearer ${Session.token}",
    };
  }

  String _toDateOnly(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return "${x.year.toString().padLeft(4, '0')}-"
        "${x.month.toString().padLeft(2, '0')}-"
        "${x.day.toString().padLeft(2, '0')}";
  }


  Future<UnavailableAppointmentsResponse> getUnavailableDates({
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
      "${ApiConfig.apiBase}/api/Appointment/unavailable-dates",
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception("Greška pri učitavanju zauzetih termina.");
    }

    final data = jsonDecode(response.body);
    return UnavailableAppointmentsResponse.fromJson(data);
  }

}




  