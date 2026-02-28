class Session {
  static String? token;
  static int? userId;
  static String? username;
  static List<String> roles = [];
  static String? fcmToken;

  static void odjava() {
    token = null;
    userId = null;
    username = null;
    fcmToken = null;
    roles = [];
  }
}
