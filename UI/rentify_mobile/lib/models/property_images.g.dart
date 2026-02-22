// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_images.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyImage _$PropertyImageFromJson(Map<String, dynamic> json) =>
    PropertyImage(
      id: (json['id'] as num?)?.toInt(),
      propertyId: (json['propertyId'] as num?)?.toInt(),
      propertyImg: json['propertyImg'] as String?,
      isMain: json['isMain'] as bool,
    );

Map<String, dynamic> _$PropertyImageToJson(PropertyImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'propertyId': instance.propertyId,
      'propertyImg': instance.propertyImg,
      'isMain': instance.isMain,
    };
