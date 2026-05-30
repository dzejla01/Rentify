// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  propertyId: (json['propertyId'] as num?)?.toInt(),
  property: json['property'] == null
      ? null
      : Property.fromJson(json['property'] as Map<String, dynamic>),
  description: json['description'] as String,
  amount: (json['amount'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  category: json['category'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'user': instance.user?.toJson(),
  'propertyId': instance.propertyId,
  'property': instance.property?.toJson(),
  'description': instance.description,
  'amount': instance.amount,
  'date': instance.date.toIso8601String(),
  'category': instance.category,
  'createdAt': instance.createdAt.toIso8601String(),
};
