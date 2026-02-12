import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rentify_desktop/config/api_config.dart';
import 'package:rentify_desktop/models/search_result.dart';
import '../utils/session.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  final String endpoint;

  BaseProvider(this.endpoint);

  
  Future<SearchResult<T>> get({Map<String, dynamic>? filter}) async {
    String url = "${ApiConfig.apiBase}/api/$endpoint";

    if (filter != null && filter.isNotEmpty) {
      final query = _buildQuery(filter);
      url = "$url?$query";
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _headers(),
    );

    _checkResponse(response);

    final json = jsonDecode(response.body);
    final result = SearchResult<T>();

    if (json is Map && json.containsKey("items")) {
      result.totalCount = json["totalCount"] ?? json["items"].length;

      for (var item in json["items"]) {
        result.items.add(fromJson(item));
      }
    } else if (json is List) {
      // fallback – API vraća listu
      result.totalCount = json.length;

      for (var item in json) {
        result.add(fromJson(item));
      }
    }

    return result;
  }

  // GET by ID
  Future<T> getById(int id) async {
    final url = "${ApiConfig.apiBase}/api/$endpoint/$id";

    final response = await http.get(
      Uri.parse(url),
      headers: _headers(),
    );

    _checkResponse(response);

    return fromJson(jsonDecode(response.body));
  }

  // POST
  Future<T> insert(dynamic request) async {
    final url = "${ApiConfig.apiBase}/api/$endpoint";

    final response = await http.post(
      Uri.parse(url),
      headers: _headers(),
      body: jsonEncode(request),
    );

    _checkResponse(response);

    return fromJson(jsonDecode(response.body));
  }

  // PUT
  Future<T> update(int id, dynamic request) async {
    final url = "${ApiConfig.apiBase}/api/$endpoint/$id";

    final response = await http.put(
      Uri.parse(url),
      headers: _headers(),
      body: jsonEncode(request),
    );

    _checkResponse(response);

    return fromJson(jsonDecode(response.body));
  }

  // DELETE
  Future<bool> delete(int? id) async {
    final url = "${ApiConfig.apiBase}/api/$endpoint/$id";

    final response = await http.delete(
      Uri.parse(url),
      headers: _headers(),
    );

    _checkResponse(response);
    return true;
  }

  // Parse JSON into model
  T fromJson(dynamic data);

  // JWT headers
  Map<String, String> _headers() {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Session.token}",
    };
  }

  // Query builder
  String _buildQuery(Map<String, dynamic> params) {
    return params.entries
        .map((e) =>
            "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}")
        .join("&");
  }

  // Error handler
  void _checkResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    }

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw Exception("API Error: ${response.statusCode} → ${response.body}");
    }
  }
}
