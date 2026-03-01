import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentify_desktop/models/appointment.dart';
import 'package:rentify_desktop/providers/base_provider.dart';
import 'package:rentify_desktop/utils/session.dart';

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

}




  