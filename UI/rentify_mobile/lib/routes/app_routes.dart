import 'package:flutter/material.dart';
import 'package:rentify_mobile/screens/appointment_list_screen.dart';
import 'package:rentify_mobile/screens/home_screen.dart';
import 'package:rentify_mobile/screens/login_screen.dart';
import 'package:rentify_mobile/screens/payment_screen.dart';
import 'package:rentify_mobile/screens/property_screen.dart';
import 'package:rentify_mobile/screens/register_screen.dart';
import 'package:rentify_mobile/screens/reservation_list_screen.dart';
import 'package:rentify_mobile/screens/tags_on_boarding_screen.dart';


class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String properties = '/properties';
  static const String taggs = '/taggs';
  static const String payments = '/payments';
  static const String reservations = '/reservations';
  static const String appointments = '/appointments';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case properties:
        return MaterialPageRoute(builder: (_) => const PropertyScreen());
      
      case reservations:
        return MaterialPageRoute(builder: (_) => const ReservationListScreen()); 

      case appointments:
        return MaterialPageRoute(builder: (_) => const AppointmentListScreen());

      case taggs:
        return MaterialPageRoute(builder: (_) => const TaggsOnboardingScreen());

      default:
        return null;
    }
  }
}
