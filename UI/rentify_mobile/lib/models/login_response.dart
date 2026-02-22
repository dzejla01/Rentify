class LoginResponse {
  int userId;
  String userName;
  String token;
  List<String> roles;

  LoginResponse({
    required this.userId,
    required this.userName,
    required this.token,
    required this.roles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json["userId"],
      userName: json["userName"],
      token: json["token"],
      roles: List<String>.from(json["roles"]),
    );
  }
}
