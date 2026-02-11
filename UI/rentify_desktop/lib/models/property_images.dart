import 'package:json_annotation/json_annotation.dart';

part 'property_images.g.dart';

@JsonSerializable()
class PropertyImage {
  int? id;
  int? propertyId;
  String? propertyImg;
  bool isMain;

  PropertyImage({
    this.id,
    this.propertyId,
    this.propertyImg,
    required this.isMain,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) =>
      _$PropertyImageFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyImageToJson(this);
}
