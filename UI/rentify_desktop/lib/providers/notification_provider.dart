import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentify_desktop/config/api_config.dart';
import 'package:rentify_desktop/helper/http_helper.dart';
import 'package:rentify_desktop/models/notification_item.dart';
import 'package:rentify_desktop/providers/base_provider.dart';
import 'package:rentify_desktop/utils/session.dart';

class NotificationProvider extends BaseProvider<NotificationItem> {
  NotificationProvider() : super("Notification") {
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => refreshUnreadCount());
    refreshUnreadCount();
  }

  Timer? _pollTimer;
  int unreadCount = 0;

  Future<void> refreshUnreadCount() async {
    if (Session.token == null) return;

    try {
      final result = await get(filter: {
        "isRead": false,
        "page": 0,
        "pageSize": 1,
        "includeTotalCount": true,
      });
      unreadCount = result.totalCount;
      notifyListeners();
    } catch (_) {
      // Tiha greska pri pozadinskom osvjezavanju badge-a - ne prikazujemo korisniku.
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

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
    await refreshUnreadCount();
    return fromJson(jsonDecode(response.body));
  }

  Future<int> markAllAsRead() async {
    final response = await http.put(
      Uri.parse("${ApiConfig.apiBase}/api/Notification/mark-all-as-read"),
      headers: HttpHelper.getHeaders(),
    );

    HttpHelper.checkResponse(response);
    final json = jsonDecode(response.body);
    await refreshUnreadCount();
    return (json['updated'] as num?)?.toInt() ?? 0;
  }
}
