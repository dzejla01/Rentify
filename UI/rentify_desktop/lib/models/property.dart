import 'package:json_annotation/json_annotation.dart';
import 'package:rentify_desktop/models/user.dart';

part 'property.g.dart';

@JsonSerializable()
class Property {
  final int id;
  final int userId;
  User? user;
  final String name;
  final String location;
  final String city;
  final double pricePerDay;
  final double pricePerMonth;
  final String numberOfsquares;
  List<String>? tags;
  final String details;
  final bool isAvailable;
  final bool isRentingPerDay;
  final bool isActiveOnApp;

  Property({
    required this.id,
    required this.userId,
    this.user,
    required this.name,
    required this.location,
    required this.city,
    required this.pricePerDay,
    required this.pricePerMonth,
    required this.numberOfsquares,
    this.tags,
    required this.details,
    required this.isAvailable,
    required this.isRentingPerDay,
    required this.isActiveOnApp,
  });

  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyToJson(this);
}
