class LoginResponse {
  final int userId;
  final String userName;
  final String fullName;
  String? userImage;
  final String token;
  final List<String> roles;
  final bool? isLoggingFirstTime;

  LoginResponse({
    required this.userId,
    required this.userName,
    this.userImage,
    required this.fullName,
    required this.token,
    required this.roles,
    this.isLoggingFirstTime,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json["userId"],
      userName: json["userName"],
      userImage: json["userImage"],
      fullName: json["fullName"],
      token: json["token"],
      roles: (json["roles"] as List)
          .map((e) => e.toString())
          .toList(),
      isLoggingFirstTime: json["isLoggingFirstTime"],
    );
  }
}