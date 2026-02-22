class Session {
  static String? token;
  static int? userId;
  static String? username;
  static List<String> roles = [];

  static void odjava() {
    token = null;
    userId = null;
    username = null;
    roles = [];
  }
}
