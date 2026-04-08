import 'package:json_annotation/json_annotation.dart';

part 'best_owner_by_year_request.g.dart';

@JsonSerializable()
class BestOwnerByYearRequest {
  final int year;

  BestOwnerByYearRequest({
    required this.year,
  });

  factory BestOwnerByYearRequest.fromJson(Map<String, dynamic> json) =>
      _$BestOwnerByYearRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BestOwnerByYearRequestToJson(this);
}