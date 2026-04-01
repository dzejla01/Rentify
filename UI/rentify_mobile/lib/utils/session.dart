import 'package:rentify_mobile/providers/auth_provider.dart';
import 'package:rentify_mobile/providers/device_token_provider.dart';

class Session {
  static String? token;
  static int? userId;
  static String? username;
  static String? fullName;
  static List<String> roles = [];
  static String? fcmToken;
  static String? userImage;
  static bool? isLoggingFirstTime;

  static Future<void> odjava({
  required DeviceTokenProvider deviceTokenProvider,
  required AuthProvider authProvider,
}) async {
  try {
    if (fcmToken != null && fcmToken!.isNotEmpty) {
      await deviceTokenProvider.unregisterFcmToken();
    }
  } catch (_) {}

  try {
    await authProvider.logout();
  } catch (_) {}

  token = null;
  userId = null;
  username = null;
  fullName = null;
  userImage = null;
  fcmToken = null;
  isLoggingFirstTime = null;
  roles = [];
}
}
