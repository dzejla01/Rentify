import 'package:flutter/material.dart';
import 'package:rentify_mobile/screens/home_screen.dart';
import 'package:rentify_mobile/screens/login_screen.dart';
import 'package:rentify_mobile/screens/register_screen.dart';


class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      default:
        return null;
    }
  }
}
