import 'package:json_annotation/json_annotation.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/models/user.dart';

part 'favorite.g.dart';

@JsonSerializable()
class Favorite {
  final int id;
  final int userId;
  final User? user;
  final int propertyId;
  final Property? property;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.userId,
    this.user,
    required this.propertyId,
    this.property,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) =>
      _$FavoriteFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteToJson(this);
}