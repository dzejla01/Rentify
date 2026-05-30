// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: (json['id'] as num).toInt(),
  reservationId: (json['reservationId'] as num).toInt(),
  reservation: json['reservation'] == null
      ? null
      : Reservation.fromJson(json['reservation'] as Map<String, dynamic>),
  name: json['name'] as String,
  comment: json['comment'] as String,
  price: (json['price'] as num).toDouble(),
  monthNumber: (json['monthNumber'] as num).toInt(),
  yearNumber: (json['yearNumber'] as num).toInt(),
  statusId: (json['statusId'] as num).toInt(),
  status: json['status'] == null
      ? null
      : Status.fromJson(json['status'] as Map<String, dynamic>),
  dateToPay: json['dateToPay'] == null
      ? null
      : DateTime.parse(json['dateToPay'] as String),
  warningDateToPay: json['warningDateToPay'] == null
      ? null
      : DateTime.parse(json['warningDateToPay'] as String),
  secondWarningDate: json['secondWarningDate'] == null
      ? null
      : DateTime.parse(json['secondWarningDate'] as String),
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'reservationId': instance.reservationId,
  'reservation': instance.reservation,
  'name': instance.name,
  'comment': instance.comment,
  'price': instance.price,
  'monthNumber': instance.monthNumber,
  'yearNumber': instance.yearNumber,
  'statusId': instance.statusId,
  'status': instance.status,
  'dateToPay': instance.dateToPay?.toIso8601String(),
  'warningDateToPay': instance.warningDateToPay?.toIso8601String(),
  'secondWarningDate': instance.secondWarningDate?.toIso8601String(),
};
