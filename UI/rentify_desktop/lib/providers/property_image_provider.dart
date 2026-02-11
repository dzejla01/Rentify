import 'dart:convert';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/property_images.dart';
import 'package:rentify_desktop/models/user.dart';
import '../utils/session.dart';
import 'package:http/http.dart' as http;

import 'base_provider.dart';

class PropertyImageProvider extends BaseProvider<PropertyImage> {
  PropertyImageProvider() : super("PropertyImage");

  @override
  PropertyImage fromJson(dynamic data) {
    return PropertyImage.fromJson(data);
  }
}