import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:rentify_desktop/config/api_config.dart';
import 'package:rentify_desktop/models/income_report.dart';
import 'package:rentify_desktop/utils/session.dart';

Map<String, String> createHeaders() => {
  "Content-Type": "application/json",
  "Authorization": "Bearer ${Session.token}",
};

class IncomeReportApi {
  Future<IncomeReport> getIncomeReport({
    required int ownerId,
    int monthsBack = 6,
    int? year,
    int? month,
  }) async {
    final qp = <String, String>{
      "ownerId": ownerId.toString(),
      "monthsBack": monthsBack.toString(),
      if (year != null) "year": year.toString(),
      if (month != null) "month": month.toString(),
    };

    final uri = Uri.parse("${ApiConfig.apiBase}/api/Report/income")
        .replace(queryParameters: qp);

    final res = await http.get(uri, headers: createHeaders());

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return IncomeReport.fromJson(data);
  }
}