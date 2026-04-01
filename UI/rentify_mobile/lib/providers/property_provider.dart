import 'dart:convert';
import 'package:rentify_mobile/config/api_config.dart';
import 'package:rentify_mobile/helper/http_helper.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/models/search_result.dart';

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

  Future<SearchResult<Property>> getRecommended({int take = 5}) async {
    final url = "${ApiConfig.apiBase}/api/Property/recommended?take=$take";

    final response = await http.get(
      Uri.parse(url),
      headers: HttpHelper.getHeaders()
    );

    HttpHelper.checkResponse(response);

    final json = jsonDecode(response.body);

    final result = SearchResult<Property>();

    if (json is List) {
      result.totalCount = json.length;
      for (final item in json) {
        result.items.add(fromJson(item));
      }
      return result;
    }

    if (json is Map && json.containsKey("items")) {
      result.totalCount = json["totalCount"] ?? (json["items"] as List).length;
      for (final item in json["items"]) {
        result.items.add(fromJson(item));
      }
      return result;
    }

    return result;
  }
}
