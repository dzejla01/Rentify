import 'package:rentify_mobile/models/property_images.dart';

import 'base_provider.dart';

class PropertyImageProvider extends BaseProvider<PropertyImage> {
  PropertyImageProvider() : super("PropertyImage");

  @override
  PropertyImage fromJson(dynamic data) {
    return PropertyImage.fromJson(data);
  }
}