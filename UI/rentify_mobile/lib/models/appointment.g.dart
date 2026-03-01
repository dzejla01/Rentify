// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  propertyId: (json['propertyId'] as num).toInt(),
  property: json['property'] == null
      ? null
      : Property.fromJson(json['property'] as Map<String, dynamic>),
  dateAppointment: json['dateAppointment'] == null
      ? null
      : DateTime.parse(json['dateAppointment'] as String),
  isApproved: json['isApproved'] as bool?,
);

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'user': instance.user?.toJson(),
      'propertyId': instance.propertyId,
      'property': instance.property?.toJson(),
      'dateAppointment': instance.dateAppointment?.toIso8601String(),
      'isApproved': instance.isApproved,
    };
