import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rentify_mobile/providers/auth_provider.dart';
import 'package:rentify_mobile/providers/device_token_provider.dart';
import 'package:rentify_mobile/providers/payment_provider.dart';
import 'package:rentify_mobile/providers/property_image_provider.dart';
import 'package:rentify_mobile/providers/property_provider.dart';
import 'package:rentify_mobile/providers/reservation_provider.dart';
import 'package:rentify_mobile/providers/review_provider.dart';
import 'package:rentify_mobile/providers/user_provider.dart';
import 'package:rentify_mobile/routes/app_routes.dart';
import 'package:rentify_mobile/screens/auth_gate_screen.dart';

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🔔 [BG] ${message.notification?.title} - ${message.notification?.body}");
  debugPrint("🔔 [BG DATA] ${message.data}");
}

Future<void> _setupFirebaseMessagingHandlers() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("🔔 [FG] ${message.notification?.title} - ${message.notification?.body}");
    debugPrint("🔔 [FG DATA] ${message.data}");
  });


  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint("📌 [OPENED] User tapped notification");
    debugPrint("📌 [OPENED DATA] ${message.data}");

  });

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    debugPrint("📌 [INITIAL] App opened from terminated by notification");
    debugPrint("📌 [INITIAL DATA] ${initialMessage.data}");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = "pk_test_51T60TkCCmkU2IHDTQPvhA3RXU3tom6LLk1qksc8vFbV2fXDOHRHh3NI1o3poP8ruSCpeZuCKsca3XVPVgJoB6Tfd00RUDpuhgH";

  await Stripe.instance.applySettings();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  await FirebaseMessaging.instance.requestPermission();

  await _setupFirebaseMessagingHandlers();

  await initializeDateFormatting('bs');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => PropertyImageProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => DeviceTokenProvider()),
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
      onGenerateRoute: AppRoutes.onGenerateRoute,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthGate(),
    );
  }
}