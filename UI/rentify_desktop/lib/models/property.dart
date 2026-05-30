import 'package:json_annotation/json_annotation.dart';
import 'package:rentify_desktop/models/city.dart';
import 'package:rentify_desktop/models/building_type.dart';
import 'package:rentify_desktop/models/user.dart';

part 'property.g.dart';

@JsonSerializable()
class Property {
  final int id;
  final int userId;
  User? user;
  final String name;
  final String location;
  final int cityId;
  City? city;
  final int buildingTypeId;
  BuildingType? buildingType;
  final double pricePerDay;
  final double pricePerMonth;
  final int squareMeters;
  List<String>? tags;
  final String details;
  final bool isAvailable;
  final bool isRentingPerDay;
  final bool isActiveOnApp;
  final String? whyRecommended;

  Property({
    required this.id,
    required this.userId,
    this.user,
    required this.name,
    required this.location,
    required this.cityId,
    this.city,
    required this.buildingTypeId,
    this.buildingType,
    required this.pricePerDay,
    required this.pricePerMonth,
    required this.squareMeters,
    this.tags,
    required this.details,
    required this.isAvailable,
    required this.isRentingPerDay,
    required this.isActiveOnApp,
    this.whyRecommended,
  });

  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyToJson(this);
}
