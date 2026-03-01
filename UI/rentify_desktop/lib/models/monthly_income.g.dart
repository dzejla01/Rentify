// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_income.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthlyIncome _$MonthlyIncomeFromJson(Map<String, dynamic> json) =>
    MonthlyIncome(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      total: (json['total'] as num).toDouble(),
    );

Map<String, dynamic> _$MonthlyIncomeToJson(MonthlyIncome instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'total': instance.total,
    };
