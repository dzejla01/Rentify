// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'best_owner_by_year.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BestOwnerByYear _$BestOwnerByYearFromJson(Map<String, dynamic> json) =>
    BestOwnerByYear(
      year: (json['year'] as num).toInt(),
      ownerId: (json['ownerId'] as num).toInt(),
      ownerName: json['ownerName'] as String,
      totalReservations: (json['totalReservations'] as num).toInt(),
    );

Map<String, dynamic> _$BestOwnerByYearToJson(BestOwnerByYear instance) =>
    <String, dynamic>{
      'year': instance.year,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'totalReservations': instance.totalReservations,
    };
