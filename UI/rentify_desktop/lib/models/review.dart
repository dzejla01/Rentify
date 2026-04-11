import 'package:json_annotation/json_annotation.dart';
import 'package:rentify_desktop/models/reservation.dart';

part 'review.g.dart';

@JsonSerializable(explicitToJson: true)
class Review {
  final int id;

  final int reservationId;
  final Reservation? reservation;

  final String comment;

  final int starRate;

  Review({
    required this.id,
    required this.reservationId,
    required this.comment,
    required this.starRate,
    this.reservation
  });

  factory Review.fromJson(Map<String, dynamic> json) =>
      _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}