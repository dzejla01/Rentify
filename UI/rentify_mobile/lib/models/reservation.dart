import 'package:json_annotation/json_annotation.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/models/user.dart';

part 'reservation.g.dart';

@JsonSerializable()
class Reservation {
  final int id;
  final int userId;
  final User? user;
  final int propertyId;
  final Property? property;
  final bool isMonthly;
  bool? isApproved;
  DateTime? createdAt;
  DateTime? startDateOfRenting;
  DateTime? endDateOfRenting;

  Reservation({
    required this.id,
    required this.userId,
    required this.user,
    required this.propertyId,
    required this.property,
    required this.isMonthly,
    this.isApproved,
    this.createdAt,
    this.startDateOfRenting,
    this.endDateOfRenting,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationToJson(this);
}
