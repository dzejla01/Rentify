import 'package:flutter/material.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/screens/appointment_screen.dart';
import 'package:rentify_desktop/screens/home_screen.dart';
import 'package:rentify_desktop/screens/login_screen.dart';
import 'package:rentify_desktop/screens/payment_screen.dart';
import 'package:rentify_desktop/screens/property_detail_or_add_screen.dart';
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
  static const String propertyDetails = '/propertyDetails';
  static const String login = '/login';
  static const String appointment = '/appointment';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case properties:
        return MaterialPageRoute(builder: (_) => const PropertyScreen());

      case reports:
        return MaterialPageRoute(builder: (_) => const ReportScreen());

      case reservations:
        return MaterialPageRoute(builder: (_) => const ReservationScreen());

      case payments:
        return MaterialPageRoute(builder: (_) => const PaymentScreen());

      case reviews:
        return MaterialPageRoute(builder: (_) => const ReviewScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case appointment:
        return MaterialPageRoute(builder: (_) => const AppointmentScreen());

      case propertyDetails:
        final args = settings.arguments as Map<String, dynamic>?;

        final property = args?['property'] as Property?;
        final isCreate = args?['isCreate'] as bool? ?? false;

        return MaterialPageRoute(
          builder: (_) =>
              PropertyDetailsScreen(property: property, isCreate: isCreate),
        );

      default:
        return null;
    }
  }
}
