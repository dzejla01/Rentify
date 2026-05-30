import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rentify_mobile/l10n/app_localizations.dart';
import 'package:rentify_mobile/providers/answer_provider.dart';
import 'package:rentify_mobile/providers/appoitment_provider.dart';
import 'package:rentify_mobile/providers/auth_provider.dart';
import 'package:rentify_mobile/providers/building_type_provider.dart';
import 'package:rentify_mobile/providers/city_provider.dart';
import 'package:rentify_mobile/providers/device_token_provider.dart';
import 'package:rentify_mobile/providers/favorite_provider.dart';
import 'package:rentify_mobile/providers/notification_provider.dart';
import 'package:rentify_mobile/providers/payment_provider.dart';
import 'package:rentify_mobile/providers/property_image_provider.dart';
import 'package:rentify_mobile/providers/property_provider.dart';
import 'package:rentify_mobile/providers/question_provider.dart';
import 'package:rentify_mobile/providers/reservation_provider.dart';
import 'package:rentify_mobile/providers/review_provider.dart';
import 'package:rentify_mobile/providers/status_provider.dart';
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

  await dotenv.load(fileName: ".env");

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;

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
        ChangeNotifierProvider(create: (_) => CityProvider()),
        ChangeNotifierProvider(create: (_) => BuildingTypeProvider()),
        ChangeNotifierProvider(create: (_) => StatusProvider()),
        ChangeNotifierProvider(create: (_) => PropertyImageProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => DeviceTokenProvider()),
        ChangeNotifierProvider(create: (_) => AppoitmentProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
        ChangeNotifierProvider(create: (_) => AnswerProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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
      home: const AuthGate(),
    );
  }
}
