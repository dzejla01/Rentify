// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  propertyId: (json['propertyId'] as num).toInt(),
  property: json['property'] == null
      ? null
      : Property.fromJson(json['property'] as Map<String, dynamic>),
  name: json['name'] as String,
  comment: json['comment'] as String,
  price: (json['price'] as num).toDouble(),
  isPayed: json['isPayed'] as bool,
  monthNumber: (json['monthNumber'] as num).toInt(),
  yearNumber: (json['yearNumber'] as num).toInt(),
  dateToPay: json['dateToPay'] == null
      ? null
      : DateTime.parse(json['dateToPay'] as String),
  warningDateToPay: json['warningDateToPay'] == null
      ? null
      : DateTime.parse(json['warningDateToPay'] as String),
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'user': instance.user,
  'propertyId': instance.propertyId,
  'property': instance.property,
  'name': instance.name,
  'comment': instance.comment,
  'price': instance.price,
  'monthNumber': instance.monthNumber,
  'yearNumber': instance.yearNumber,
  'isPayed': instance.isPayed,
  'dateToPay': instance.dateToPay?.toIso8601String(),
  'warningDateToPay': instance.warningDateToPay?.toIso8601String(),
};
