import 'dart:convert';
import 'package:rentify_mobile/config/api_config.dart';
import 'package:rentify_mobile/helper/http_helper.dart';
import 'package:rentify_mobile/models/payment.dart';
import 'package:http/http.dart' as http;

import 'base_provider.dart';

class PaymentProvider extends BaseProvider<Payment> {
  PaymentProvider() : super("payment");

  @override
  Payment fromJson(dynamic data) {
    return Payment.fromJson(data);
  }

  Future<String> createNewIntent(Map<String, dynamic> request) async {
  final url = "${ApiConfig.apiBase}/api/payment/create-new-intent";

  final response = await http.post(
    Uri.parse(url),
    headers: HttpHelper.getHeaders(),
    body: jsonEncode(request)
  );

  HttpHelper.checkResponse(response);

  final data = jsonDecode(response.body);

  return data["clientSecret"] as String;
}
}