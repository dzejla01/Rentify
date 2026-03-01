import 'package:json_annotation/json_annotation.dart';

part 'monthly_income.g.dart';

@JsonSerializable()
class MonthlyIncome {
  final int year;
  final int month;
  final double total;

  MonthlyIncome({
    required this.year,
    required this.month,
    required this.total,
  });

  String get label => "${month.toString().padLeft(2, '0')}.$year";

  factory MonthlyIncome.fromJson(Map<String, dynamic> json) =>
      _$MonthlyIncomeFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyIncomeToJson(this);
}
