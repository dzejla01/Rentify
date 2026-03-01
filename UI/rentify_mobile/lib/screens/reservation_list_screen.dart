import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/screens/base_screen.dart';
import 'package:rentify_mobile/utils/session.dart';
import 'package:rentify_mobile/models/search_result.dart';
import 'package:rentify_mobile/helper/univerzal_pagging_helper.dart';
import 'package:rentify_mobile/models/reservation.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/providers/reservation_provider.dart';
import 'package:rentify_mobile/providers/property_provider.dart';
import 'package:rentify_mobile/widgets/swipe_widget.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  late ReservationProvider _reservationProvider;
  late PropertyProvider _propertyProvider;

  late UniversalPagingProvider<Reservation> _paging;

  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  Map<int, Property> _propertiesMap = {};

  bool _metaLoading = false;
  String? _metaError;

  @override
  void initState() {
    super.initState();

    _reservationProvider = context.read<ReservationProvider>();
    _propertyProvider = context.read<PropertyProvider>();

    _paging = UniversalPagingProvider<Reservation>(
      pageSize: 6,
      fetcher: ({
        required int page,
        required int pageSize,
        String? filter,
        Map<String, dynamic>? extra,
        bool includeTotalCount = true,
      }) async {
        final userId = Session.userId;
        if (userId == null) {
          return SearchResult<Reservation>()..totalCount = 0;
        }

        final f = <String, dynamic>{
          "userId": userId,
          "page": page,
          "pageSize": pageSize,
          "includeTotalCount": includeTotalCount,
          if (filter != null && filter.trim().isNotEmpty) "FTS": filter.trim(),
          ...?extra,
        };

        return await _reservationProvider.get(filter: f);
      },
    );

    _paging.addListener(_onPagingChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshWithMeta();
    });
  }

  void _onPagingChanged() {
    if (!mounted) return;
    if (!_paging.isLoading) {
      _loadPropertiesForPage();
    }
  }

  Future<void> _refreshWithMeta() async {
    await _paging.refresh();
    if (!mounted) return;
    await _loadPropertiesForPage();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      await _paging.search(value);
      if (!mounted) return;
      await _loadPropertiesForPage();
    });
  }

  Future<void> _loadPropertiesForPage() async {
    if (!mounted) return;

    setState(() {
      _metaLoading = true;
      _metaError = null;
    });

    try {
      final reservations = _paging.items;

      final Map<int, Property> loaded = {};
      for (final r in reservations) {
        if (!loaded.containsKey(r.propertyId)) {
          loaded[r.propertyId] = await _propertyProvider.getById(r.propertyId);
        }
      }

      if (!mounted) return;
      setState(() {
        _propertiesMap = loaded;
        _metaLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _metaLoading = false;
        _metaError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseMobileScreen(
      title: "Rezervacije",
      NameAndSurname: (Session.username ?? "").trim(),
      userUsername: Session.username ?? "Nepoznato",
      onLogout: () => Session.odjava(),
      child: Container(
        color: const Color(0xFFF6F7FB),
        child: Column(
          children: [
            _SearchBar(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              onClear: () async {
                _searchCtrl.clear();
                await _paging.search("");
                if (!mounted) return;
                await _loadPropertiesForPage();
              },
              hint: "Pretraga (nekretnina / period / tip...)",
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshWithMeta,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    if ((_metaError ?? _paging.error) != null &&
                        _paging.items.isEmpty)
                      _ErrorState(
                        message: (_metaError ?? _paging.error)!,
                        onRetry: _refreshWithMeta,
                      )
                    else if (_paging.isLoading && _paging.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_paging.items.isEmpty)
                      const _EmptyState(text: "Trenutno nema rezervacija.")
                    else ...[
                      SwipePagedList<Reservation>(
                        provider: _paging,
                        separatorHeight: 12,
                        itemBuilder: (context, r) {
                          final p = _propertiesMap[r.propertyId];
                          final status = StatusMapper.fromApproved(r.isApproved);

                          return _ReservationCard(
                            propertyName: p?.name ?? "Učitavanje...",
                            typeText: r.isMonthly == true
                                ? "Mjesečno"
                                : "Kratki boravak",
                            periodText: _periodText(
                              start: r.startDateOfRenting,
                              end: r.endDateOfRenting,
                            ),
                            createdAtText: _createdAtText(r.createdAt!),
                            status: status,
                            loadingMeta: _metaLoading && p == null,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _periodText({required DateTime? start, required DateTime? end}) {
    String fmt(DateTime? d) {
      if (d == null) return "-";
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      final yy = d.year.toString();
      return "$dd.$mm.$yy";
    }

    if (start == null && end == null) return "-";
    return "${fmt(start)} → ${fmt(end)}";
  }

  static String _createdAtText(DateTime createdAt) {
    // prikaz: 01.03.2026 • 11:05
    final local = createdAt.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final yy = local.year.toString();
    final hh = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return "$dd.$mm.$yy • $hh:$mi";
  }

  @override
  void dispose() {
    _paging.removeListener(_onPagingChanged);
    _debounce?.cancel();
    _searchCtrl.dispose();
    _paging.dispose();
    super.dispose();
  }
}

/// ==================== CARD UI ====================

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.propertyName,
    required this.typeText,
    required this.periodText,
    required this.createdAtText,
    required this.status,
    this.loadingMeta = false,
  });

  final String propertyName;
  final String typeText;
  final String periodText;
  final String createdAtText;
  final _Status status;
  final bool loadingMeta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row: icon + name + status chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6E5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: Color(0xFF5F9F3B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      propertyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1F2A1F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _MiniRow(icon: Icons.category_rounded, text: typeText),
                    const SizedBox(height: 6),
                    _MiniRow(icon: Icons.date_range_rounded, text: periodText),
                    const SizedBox(height: 6),
                    _MiniRow(icon: Icons.bookmark_added_rounded, text: "rezervacija poslana: ${createdAtText}"),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusPill(status: status),
            ],
          ),

          const SizedBox(height: 12),

          // alert-like row (created at)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _alertBg(status),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _alertBorder(status)),
            ),
            child: Row(
              children: [
                Icon(
                  _alertIcon(status),
                  size: 18,
                  color: _alertFg(status),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _alertText(status, createdAtText),
                    style: TextStyle(
                      fontSize: 12.7,
                      fontWeight: FontWeight.w900,
                      color: _alertFg(status),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (loadingMeta)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _alertIcon(_Status s) {
    switch (s) {
      case _Status.accepted:
        return Icons.check_circle_rounded;
      case _Status.pending:
        return Icons.hourglass_bottom_rounded;
      case _Status.rejected:
        return Icons.cancel_rounded;
    }
  }

  static String _alertText(_Status s, String createdAtText) {
    switch (s) {
      case _Status.accepted:
        return "Rezervacija je prihvaćena, za otkazivanje, kontaktirajte vlasnika";
      case _Status.pending:
        return "Rezervacija je na čekanju";
      case _Status.rejected:
        return "Rezervacija je odbijena, kontaktirajte vlasnika za detalje";
    }
  }

  static Color _alertBg(_Status s) {
    switch (s) {
      case _Status.accepted:
        return const Color(0xFFEAF6E5);
      case _Status.pending:
        return const Color(0xFFFFF3E0);
      case _Status.rejected:
        return const Color(0xFFFFE5E5);
    }
  }

  static Color _alertBorder(_Status s) {
    switch (s) {
      case _Status.accepted:
        return const Color(0xFFBFE6B2);
      case _Status.pending:
        return const Color(0xFFFFD59A);
      case _Status.rejected:
        return const Color(0xFFFFBDBD);
    }
  }

  static Color _alertFg(_Status s) {
    switch (s) {
      case _Status.accepted:
        return const Color(0xFF2E7D32);
      case _Status.pending:
        return const Color(0xFFEF6C00);
      case _Status.rejected:
        return const Color(0xFFE53935);
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final _Status status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  const _MiniRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF5F9F3B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.8,
              fontWeight: FontWeight.w800,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}

/// ==================== STATUS ====================

enum _Status { accepted, pending, rejected }

extension StatusMapper on _Status {
  static _Status fromApproved(bool? isApproved) {
    if (isApproved == true) return _Status.accepted;
    if (isApproved == false) return _Status.rejected;
    return _Status.pending;
  }

  String get label {
    switch (this) {
      case _Status.accepted:
        return "Prihvaćeno";
      case _Status.pending:
        return "Na čekanju";
      case _Status.rejected:
        return "Odbijeno";
    }
  }

  Color get color {
    switch (this) {
      case _Status.accepted:
        return Colors.green;
      case _Status.pending:
        return Colors.orange;
      case _Status.rejected:
        return const Color(0xFFE53935);
    }
  }
}

/// ==================== STATES ====================

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Pokušaj ponovo"),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.hint,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
          ),
        ),
      ),
    );
  }
}