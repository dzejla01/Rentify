import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/models/notification_item.dart';
import 'package:rentify_desktop/providers/notification_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const Color rentifyGreen = Color(0xFFA9C64A);
  static const Color rentifyGreenDark = Color(0xFF5F9F3B);

  final List<NotificationItem> _items = [];
  Timer? _timer;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final result = await context.read<NotificationProvider>().get(
        filter: {
          "Page": 0,
          "PageSize": 50,
          "IncludeTotalCount": true,
        },
      );
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(result.items);
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _markAsRead(NotificationItem item) async {
    if (item.isRead) return;
    await context.read<NotificationProvider>().markAsRead(item.id);
    await _load(silent: true);
  }

  Future<void> _markAllAsRead() async {
    await context.read<NotificationProvider>().markAllAsRead();
    await _load(silent: true);
  }

  String _fmt(DateTime value) {
    final d = value.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return "$day.$month.${d.year}. $hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _items.where((x) => !x.isRead).length;

    return RentifyBasePage(
      title: "Notifikacije",
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              children: [
                Text(
                  unreadCount == 0
                      ? "Sve je procitano"
                      : "Neprocitano: $unreadCount",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF2F2F2F),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: unreadCount == 0 ? null : _markAllAsRead,
                  icon: const Icon(Icons.done_all_rounded),
                  label: const Text("Oznaci sve"),
                  style: TextButton.styleFrom(
                    foregroundColor: rentifyGreenDark,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _load,
                  tooltip: "Osvježi",
                  color: rentifyGreenDark,
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildMessage(
                        Icons.error_outline_rounded,
                        "Greška pri učitavanju",
                        "Greška prilikom komunikacije sa serverom.",
                      )
                    : _items.isEmpty
                        ? _buildMessage(
                            Icons.notifications_none_rounded,
                            "Nema notifikacija",
                            "Ovdje će se prikazati obavijesti o rezervacijama, terminima i plaćanjima.",
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return _NotificationCard(
                                  item: item,
                                  createdAt: _fmt(item.createdAt),
                                  onTap: () => _markAsRead(item),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(IconData icon, String title, String message) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x15000000)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF7A7A7A), size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFF7A7A7A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.createdAt,
    required this.onTap,
  });

  final NotificationItem item;
  final String createdAt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: unread ? const Color(0xFFF2F9E8) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: unread
                    ? const Color(0xFFA9C64A)
                    : const Color(0x11000000),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  unread
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  color: unread
                      ? const Color(0xFF5F9F3B)
                      : const Color(0xFF7A7A7A),
                  size: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF616161),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        createdAt,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                    ],
                  ),
                ),
                if (unread)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5F9F3B),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
