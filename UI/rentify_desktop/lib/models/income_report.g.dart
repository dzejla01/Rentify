// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncomeReport _$IncomeReportFromJson(Map<String, dynamic> json) => IncomeReport(
  monthly: (json['monthly'] as List<dynamic>)
      .map((e) => MonthlyIncome.fromJson(e as Map<String, dynamic>))
      .toList(),
  byProperty: (json['byProperty'] as List<dynamic>)
      .map((e) => PropertyIncome.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$IncomeReportToJson(IncomeReport instance) =>
    <String, dynamic>{
      'monthly': instance.monthly,
      'byProperty': instance.byProperty,
    };
