class LoginResponse {
  final int userId;
  final String userName;
  final String token;
  final List<String> roles;
  final bool? isLoggingFirstTime;

  LoginResponse({
    required this.userId,
    required this.userName,
    required this.token,
    required this.roles,
    this.isLoggingFirstTime,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json["userId"],
      userName: json["userName"],
      token: json["token"],
      roles: (json["roles"] as List)
          .map((e) => e.toString())
          .toList(),
      isLoggingFirstTime: json["isLoggingFirstTime"],
    );
  }
}