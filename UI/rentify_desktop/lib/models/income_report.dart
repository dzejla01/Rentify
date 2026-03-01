import 'package:json_annotation/json_annotation.dart';
import 'package:rentify_desktop/models/monthly_income.dart';
import 'package:rentify_desktop/models/property_income.dart';

part 'income_report.g.dart';

@JsonSerializable()
class IncomeReport {
  final List<MonthlyIncome> monthly;
  final List<PropertyIncome> byProperty;

  IncomeReport({
    required this.monthly,
    required this.byProperty,
  });

  factory IncomeReport.fromJson(Map<String, dynamic> json) =>
      _$IncomeReportFromJson(json);

  Map<String, dynamic> toJson() => _$IncomeReportToJson(this);
}