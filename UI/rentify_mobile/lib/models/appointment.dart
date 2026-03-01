import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'property.dart';

part 'appointment.g.dart';

@JsonSerializable(explicitToJson: true)
class Appointment {
  final int id;
  final int userId;
  final User? user;

  final int propertyId;
  final Property? property;

  final DateTime? dateAppointment;
  final bool? isApproved;

  Appointment({
    required this.id,
    required this.userId,
    this.user,
    required this.propertyId,
    this.property,
    this.dateAppointment,
    this.isApproved,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}