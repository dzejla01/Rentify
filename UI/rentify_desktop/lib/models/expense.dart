import 'package:json_annotation/json_annotation.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/user.dart';

part 'expense.g.dart';

@JsonSerializable(explicitToJson: true)
class Expense {
  final int id;
  final int userId;
  final User? user;
  final int? propertyId;
  final Property? property;
  final String description;
  final double amount;
  final DateTime date;
  final String category;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.userId,
    this.user,
    this.propertyId,
    this.property,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}
