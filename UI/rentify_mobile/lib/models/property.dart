import 'package:json_annotation/json_annotation.dart';
import 'package:rentify_mobile/models/city.dart';
import 'package:rentify_mobile/models/building_type.dart';
import 'package:rentify_mobile/models/user.dart';

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
  final double squareMeters;
  List<String>? tags;
  final String details;
  final bool isAvailable;
  final bool isRentingPerDay;
  final bool isActiveOnApp;
  final String? whyRecommended;
  final double? latitude;
  final double? longitude;

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
    this.latitude,
    this.longitude,
  });

  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyToJson(this);
}
