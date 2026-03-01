import 'package:json_annotation/json_annotation.dart';

part 'property_income.g.dart';

@JsonSerializable()
class PropertyIncome {
  final int propertyId;
  final String propertyName;
  final double total;

  PropertyIncome({
    required this.propertyId,
    required this.propertyName,
    required this.total,
  });

  factory PropertyIncome.fromJson(Map<String, dynamic> json) =>
      _$PropertyIncomeFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyIncomeToJson(this);
}