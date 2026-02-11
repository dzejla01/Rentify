import 'dart:convert';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/user.dart';
import '../utils/session.dart';
import 'package:http/http.dart' as http;

import 'base_provider.dart';

class PropertyProvider extends BaseProvider<Property> {
  PropertyProvider() : super("Property");

  Property? property;

  @override
  Property fromJson(dynamic data) {
    return Property.fromJson(data);
  }
}