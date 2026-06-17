import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/helper/exception_read_helper.dart';
import 'package:rentify_mobile/models/notification_item.dart';
import 'package:rentify_mobile/providers/notification_provider.dart';
import 'package:rentify_mobile/screens/base_screen.dart';
import 'package:rentify_mobile/utils/session.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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
        _error = extractErrorMessage(e);
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

    return BaseMobileScreen(
      title: "Notifikacije",
      NameAndSurname: Session.fullName ?? "Korisnik",
      userUsername: Session.username ?? "",
      userImageAsset: Session.userImage,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    unreadCount == 0
                        ? "Sve je procitano"
                        : "Neprocitano: $unreadCount",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: unreadCount == 0 ? null : _markAllAsRead,
                  icon: const Icon(Icons.done_all_rounded),
                  label: const Text("Oznaci sve"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _MessageBox(
                icon: Icons.error_outline_rounded,
                title: "Greska pri ucitavanju",
                message: _error!,
              )
            else if (_items.isEmpty)
              const _MessageBox(
                icon: Icons.notifications_none_rounded,
                title: "Nema notifikacija",
                message: "Ovdje ce se prikazati obavijesti o rezervacijama i placanjima.",
              )
            else
              ..._items.map(
                (item) => _NotificationCard(
                  item: item,
                  createdAt: _fmt(item.createdAt),
                  onTap: () => _markAsRead(item),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: unread ? const Color(0xFFA9C64A) : const Color(0x11000000),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  unread
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  color: unread ? const Color(0xFF5F9F3B) : const Color(0xFF7A7A7A),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF616161),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        createdAt,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                    ],
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

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7A7A7A)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
