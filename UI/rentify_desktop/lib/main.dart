import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/providers/auth_provider.dart';
import 'package:rentify_desktop/providers/user_provider.dart';
import 'package:rentify_desktop/routes/app_routes.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider())
      ],
      child: const RentifyApp(),
    ),
  );
}

class RentifyApp extends StatelessWidget {
  const RentifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rentify',
      routes: AppRoutes.routes,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
    );
  }
}
