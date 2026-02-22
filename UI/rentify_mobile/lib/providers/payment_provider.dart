import 'dart:convert';
import 'package:rentify_mobile/models/payment.dart';

import '../utils/session.dart';
import 'package:http/http.dart' as http;

import 'base_provider.dart';

class PaymentProvider extends BaseProvider<Payment> {
  PaymentProvider() : super("Payment");

  @override
  Payment fromJson(dynamic data) {
    return Payment.fromJson(data);
  }
}