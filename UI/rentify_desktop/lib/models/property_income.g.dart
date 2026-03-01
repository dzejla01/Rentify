// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_income.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyIncome _$PropertyIncomeFromJson(Map<String, dynamic> json) =>
    PropertyIncome(
      propertyId: (json['propertyId'] as num).toInt(),
      propertyName: json['propertyName'] as String,
      total: (json['total'] as num).toDouble(),
    );

Map<String, dynamic> _$PropertyIncomeToJson(PropertyIncome instance) =>
    <String, dynamic>{
      'propertyId': instance.propertyId,
      'propertyName': instance.propertyName,
      'total': instance.total,
    };
