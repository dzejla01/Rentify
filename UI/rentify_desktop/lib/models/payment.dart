import 'package:json_annotation/json_annotation.dart';
import 'package:rentify_desktop/models/reservation.dart';
import 'package:rentify_desktop/models/status.dart';
import 'package:rentify_desktop/models/user.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final int id;
  final int reservationId;
  Reservation? reservation;
  final String name;
  final String comment;
  final double price;
  final int monthNumber;
  final int yearNumber;
  final int statusId;
  Status? status;
  DateTime? dateToPay;
  DateTime? warningDateToPay;
  DateTime? secondWarningDate;

  Payment({
    required this.id,
    required this.reservationId,
    this.reservation,
    required this.name,
    required this.comment,
    required this.price,
    required this.monthNumber,
    required this.yearNumber,
    required this.statusId,
    this.status,
    this.dateToPay,
    this.warningDateToPay,
    this.secondWarningDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  String? get paymentStatus => status?.name;
  String? get reservationStatus => reservation?.status?.name;

  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
