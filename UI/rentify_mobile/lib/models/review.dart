import 'package:json_annotation/json_annotation.dart';

import 'user.dart';
import 'property.dart';

part 'review.g.dart';

@JsonSerializable(explicitToJson: true)
class Review {
  final int id;

  final int userId;
  final User? user;

  final int propertyId;
  final Property? property;

  final String comment;

  final int starRate;

  Review({
    required this.id,
    required this.userId,
    this.user,
    required this.propertyId,
    this.property,
    required this.comment,
    required this.starRate,
  });

  factory Review.fromJson(Map<String, dynamic> json) =>
      _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}