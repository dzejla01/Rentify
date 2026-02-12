// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Property _$PropertyFromJson(Map<String, dynamic> json) => Property(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  name: json['name'] as String,
  location: json['location'] as String,
  city: json['city'] as String,
  pricePerDay: (json['pricePerDay'] as num).toDouble(),
  pricePerMonth: (json['pricePerMonth'] as num).toDouble(),
  numberOfsquares: json['numberOfsquares'] as String,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  details: json['details'] as String,
  isAvailable: json['isAvailable'] as bool,
  isRentingPerDay: json['isRentingPerDay'] as bool,
  isActiveOnApp: json['isActiveOnApp'] as bool,
);

Map<String, dynamic> _$PropertyToJson(Property instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'location': instance.location,
  'city': instance.city,
  'pricePerDay': instance.pricePerDay,
  'pricePerMonth': instance.pricePerMonth,
  'numberOfsquares': instance.numberOfsquares,
  'tags': instance.tags,
  'details': instance.details,
  'isAvailable': instance.isAvailable,
  'isRentingPerDay': instance.isRentingPerDay,
  'isActiveOnApp': instance.isActiveOnApp,
};
