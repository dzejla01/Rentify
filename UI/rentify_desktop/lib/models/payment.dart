import 'package:json_annotation/json_annotation.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/reservation.dart';
import 'package:rentify_desktop/models/user.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final int id;
  // ako bude se vracalo ovdj ide userid user, prpertyid, property
  final int reservationId;
  Reservation? reservation;
  final String name;
  final String comment;
  final double price;
  final int monthNumber;
  final int yearNumber;
  final bool isPayed;
  DateTime? dateToPay;
  DateTime? warningDateToPay;  

  Payment({
    required this.id,
    required this.reservationId,
    this.reservation,
    required this.name,
    required this.comment,
    required this.price,
    required this.isPayed,
    required this.monthNumber,
    required this.yearNumber,
    this.dateToPay,
    this.warningDateToPay,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
