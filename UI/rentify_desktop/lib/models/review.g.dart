// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: (json['id'] as num).toInt(),
  reservationId: (json['reservationId'] as num).toInt(),
  comment: json['comment'] as String,
  starRate: (json['starRate'] as num).toInt(),
  reservation: json['reservation'] == null
      ? null
      : Reservation.fromJson(json['reservation'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'reservationId': instance.reservationId,
  'reservation': instance.reservation?.toJson(),
  'comment': instance.comment,
  'starRate': instance.starRate,
};
