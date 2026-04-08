import 'package:json_annotation/json_annotation.dart';

part 'best_owner_by_year.g.dart';

@JsonSerializable()
class BestOwnerByYear {
  final int year;
  final int ownerId;
  final String ownerName;
  final int totalReservations;

  BestOwnerByYear({
    required this.year,
    required this.ownerId,
    required this.ownerName,
    required this.totalReservations,
  });

  factory BestOwnerByYear.fromJson(Map<String, dynamic> json) =>
      _$BestOwnerByYearFromJson(json);

  Map<String, dynamic> toJson() => _$BestOwnerByYearToJson(this);
}