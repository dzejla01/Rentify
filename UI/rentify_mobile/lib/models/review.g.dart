// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  propertyId: (json['propertyId'] as num).toInt(),
  property: json['property'] == null
      ? null
      : Property.fromJson(json['property'] as Map<String, dynamic>),
  comment: json['comment'] as String,
  starRate: (json['starRate'] as num).toInt(),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'user': instance.user?.toJson(),
  'propertyId': instance.propertyId,
  'property': instance.property?.toJson(),
  'comment': instance.comment,
  'starRate': instance.starRate,
};
