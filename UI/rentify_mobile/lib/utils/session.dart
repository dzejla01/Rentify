class Session {
  static String? token;
  static int? userId;
  static String? username;
  static List<String> roles = [];
  static String? fcmToken;
  static bool? isLoggingFirstTime;
  static List<String>? taggs = []; 

  static void odjava() {
    token = null;
    userId = null;
    username = null;
    fcmToken = null;
    isLoggingFirstTime = null;
    taggs = null;
    roles = [];
  }
}
