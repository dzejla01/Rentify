import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentify_mobile/config/api_config.dart';
import 'package:rentify_mobile/helper/http_helper.dart';
import 'package:rentify_mobile/models/notification_item.dart';
import 'package:rentify_mobile/providers/base_provider.dart';

class NotificationProvider extends BaseProvider<NotificationItem> {
  NotificationProvider() : super("Notification");

  @override
  NotificationItem fromJson(dynamic data) {
    return NotificationItem.fromJson(Map<String, dynamic>.from(data));
  }

  Future<NotificationItem> markAsRead(int id) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.apiBase}/api/Notification/$id/mark-as-read"),
      headers: HttpHelper.getHeaders(),
    );

    HttpHelper.checkResponse(response);
    return fromJson(jsonDecode(response.body));
  }

  Future<int> markAllAsRead() async {
    final response = await http.put(
      Uri.parse("${ApiConfig.apiBase}/api/Notification/mark-all-as-read"),
      headers: HttpHelper.getHeaders(),
    );

    HttpHelper.checkResponse(response);
    final json = jsonDecode(response.body);
    return (json['updated'] as num?)?.toInt() ?? 0;
  }
}
