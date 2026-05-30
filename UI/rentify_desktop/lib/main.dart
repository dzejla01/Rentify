import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/l10n/app_localizations.dart';
import 'package:rentify_desktop/providers/appointment_provider.dart';
import 'package:rentify_desktop/providers/auth_provider.dart';
import 'package:rentify_desktop/providers/building_type_provider.dart';
import 'package:rentify_desktop/providers/city_provider.dart';
import 'package:rentify_desktop/providers/notification_provider.dart';
import 'package:rentify_desktop/providers/payment_provider.dart';
import 'package:rentify_desktop/providers/property_image_provider.dart';
import 'package:rentify_desktop/providers/property_provider.dart';
import 'package:rentify_desktop/providers/reservation_provider.dart';
import 'package:rentify_desktop/providers/review_provider.dart';
import 'package:rentify_desktop/providers/expense_provider.dart';
import 'package:rentify_desktop/providers/status_provider.dart';
import 'package:rentify_desktop/providers/user_provider.dart';
import 'package:rentify_desktop/routes/app_routes.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => CityProvider()),
        ChangeNotifierProvider(create: (_) => BuildingTypeProvider()),
        ChangeNotifierProvider(create: (_) => StatusProvider()),
        ChangeNotifierProvider(create: (_) => PropertyImageProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => AppoitmentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
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
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('bs'),
        Locale('en'),
      ],
      locale: const Locale('bs'),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
    );
  }
}
