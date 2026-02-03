import 'package:flutter/material.dart';
import 'package:rentify_desktop/screens/home_screen.dart';
import 'package:rentify_desktop/screens/login_screen.dart';
import 'package:rentify_desktop/screens/payment_screen.dart';
import 'package:rentify_desktop/screens/property_screen.dart';
import 'package:rentify_desktop/screens/report_screen.dart';
import 'package:rentify_desktop/screens/reservation_screen.dart';
import 'package:rentify_desktop/screens/review_screen.dart';


class AppRoutes {
  static const String home = '/home';
  static const String properties = '/properties';
  static const String reports = '/reports';
  static const String reservations = '/reservations';
  static const String payments = '/payments';
  static const String reviews = '/reviews';
  static const String login = '/login';

  static final Map<String, WidgetBuilder> routes = {
    properties: (_) => const PropertyScreen(),
    reports: (_) => const ReportScreen(),
    home: (_) => const HomeScreen(),
    reservations: (_) => const ReservationScreen(),
    payments: (_) => const PaymentScreen(),
    reviews: (_) => const ReviewScreen(),
    login: (_) => const LoginScreen()
  };
}
