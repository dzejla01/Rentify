// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Property _$PropertyFromJson(Map<String, dynamic> json) => Property(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  name: json['name'] as String,
  location: json['location'] as String,
  cityId: (json['cityId'] as num).toInt(),
  city: json['city'] == null
      ? null
      : City.fromJson(json['city'] as Map<String, dynamic>),
  buildingTypeId: (json['buildingTypeId'] as num).toInt(),
  buildingType: json['buildingType'] == null
      ? null
      : BuildingType.fromJson(json['buildingType'] as Map<String, dynamic>),
  pricePerDay: (json['pricePerDay'] as num).toDouble(),
  pricePerMonth: (json['pricePerMonth'] as num).toDouble(),
  squareMeters: (json['squareMeters'] as num).toDouble(),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  details: json['details'] as String,
  isAvailable: json['isAvailable'] as bool,
  isRentingPerDay: json['isRentingPerDay'] as bool,
  isActiveOnApp: json['isActiveOnApp'] as bool,
  whyRecommended: json['whyRecommended'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PropertyToJson(Property instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'user': instance.user,
  'name': instance.name,
  'location': instance.location,
  'cityId': instance.cityId,
  'city': instance.city,
  'buildingTypeId': instance.buildingTypeId,
  'buildingType': instance.buildingType,
  'pricePerDay': instance.pricePerDay,
  'pricePerMonth': instance.pricePerMonth,
  'squareMeters': instance.squareMeters,
  'tags': instance.tags,
  'details': instance.details,
  'isAvailable': instance.isAvailable,
  'isRentingPerDay': instance.isRentingPerDay,
  'isActiveOnApp': instance.isActiveOnApp,
  'whyRecommended': instance.whyRecommended,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
