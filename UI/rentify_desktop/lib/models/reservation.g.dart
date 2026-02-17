// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reservation _$ReservationFromJson(Map<String, dynamic> json) => Reservation(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  propertyId: (json['propertyId'] as num).toInt(),
  property: json['property'] == null
      ? null
      : Property.fromJson(json['property'] as Map<String, dynamic>),
  isMonthly: json['isMonthly'] as bool,
  isApproved: json['isApproved'] as bool?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  startDateOfRenting: json['startDateOfRenting'] == null
      ? null
      : DateTime.parse(json['startDateOfRenting'] as String),
  endDateOfRenting: json['endDateOfRenting'] == null
      ? null
      : DateTime.parse(json['endDateOfRenting'] as String),
);

Map<String, dynamic> _$ReservationToJson(Reservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'user': instance.user,
      'propertyId': instance.propertyId,
      'property': instance.property,
      'isMonthly': instance.isMonthly,
      'isApproved': instance.isApproved,
      'createdAt': instance.createdAt?.toIso8601String(),
      'startDateOfRenting': instance.startDateOfRenting?.toIso8601String(),
      'endDateOfRenting': instance.endDateOfRenting?.toIso8601String(),
    };
