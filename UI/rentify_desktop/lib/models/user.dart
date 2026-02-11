import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  DateTime? dateOfBirth;
  String? userImage;
  final bool isActive;
  final bool isVlasnik;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  String? phoneNumber;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    this.dateOfBirth,
    this.userImage,
    required this.isActive,
    required this.isVlasnik,
    required this.createdAt,
    this.lastLoginAt,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
