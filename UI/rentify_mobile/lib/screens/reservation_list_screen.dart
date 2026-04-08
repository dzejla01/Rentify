import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/providers/auth_provider.dart';
import 'package:rentify_mobile/providers/device_token_provider.dart';
import 'package:rentify_mobile/providers/user_provider.dart';
import 'package:rentify_mobile/routes/app_routes.dart';
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
  late UserProvider _userProvider;

  late UniversalPagingProvider<Reservation> _paging;

  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  Map<int, Property> _propertiesMap = {};

  bool _metaLoading = false;
  String? _metaError;

  String _fullName = "";
  bool _userLoading = false;

  String? _selectedStatus; // null = sve, ili "Odobreno" / "Na čekanju" / "Završeno"

  Future<String> _getUserFullName(int userId) async {
    final u = await _userProvider.getById(userId);
    final first = (u.firstName ?? "").trim();
    final last = (u.lastName ?? "").trim();
    final full = "$first $last".trim();
    return full.isEmpty ? (Session.username ?? "Nepoznato") : full;
  }

  Future<void> _loadHeaderUserFullName() async {
    final userId = Session.userId;
    if (userId == null) return;

    if (!mounted) return;
    setState(() => _userLoading = true);

    try {
      final name = await _getUserFullName(userId);
      if (!mounted) return;
      setState(() => _fullName = name);
    } catch (_) {
      if (!mounted) return;
      setState(() => _fullName = (Session.username ?? "Nepoznato"));
    } finally {
      if (mounted) setState(() => _userLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    _reservationProvider = context.read<ReservationProvider>();
    _propertyProvider = context.read<PropertyProvider>();
    _userProvider = context.read<UserProvider>();

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
          if (_selectedStatus != null) "status": _selectedStatus,
          ...?extra,
        };

        return await _reservationProvider.get(filter: f);
      },
    );

    _paging.addListener(_onPagingChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadHeaderUserFullName();
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

  Future<void> _changeStatusFilter(String? status) async {
    if (!mounted) return;

    setState(() {
      _selectedStatus = status;
    });

    await _paging.refresh();
    if (!mounted) return;
    await _loadPropertiesForPage();
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
      NameAndSurname: Session.fullName ?? _fullName,
      userUsername: Session.username ?? "Nepoznato",
      userImageAsset: Session.userImage,
      onLogout: () async {
        await Session.odjava(
          deviceTokenProvider: context.read<DeviceTokenProvider>(),
          authProvider: context.read<AuthProvider>(),
        );

        if (!context.mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      },
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

            _StatusFilterBar(
              selectedStatus: _selectedStatus,
              onTapAll: () => _changeStatusFilter(null),
              onTapApproved: () => _changeStatusFilter("Odobreno"),
              onTapPending: () => _changeStatusFilter("Na čekanju"),
              onTapFinished: () => _changeStatusFilter("Završeno"),
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
                          final status = ReservationStatusMapper.fromString(r.status);

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

/// ==================== STATUS FILTER ====================

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({
    required this.selectedStatus,
    required this.onTapAll,
    required this.onTapApproved,
    required this.onTapPending,
    required this.onTapFinished,
  });

  final String? selectedStatus;
  final VoidCallback onTapAll;
  final VoidCallback onTapApproved;
  final VoidCallback onTapPending;
  final VoidCallback onTapFinished;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChipButton(
              label: "Sve",
              selected: selectedStatus == null,
              onTap: onTapAll,
              selectedColor: const Color(0xFF5F9F3B),
            ),
            const SizedBox(width: 8),
            _FilterChipButton(
              label: "Odobrene",
              selected: selectedStatus == "Odobreno",
              onTap: onTapApproved,
              selectedColor: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            _FilterChipButton(
              label: "Na čekanju",
              selected: selectedStatus == "Na čekanju",
              onTap: onTapPending,
              selectedColor: const Color(0xFFEF6C00),
            ),
            const SizedBox(width: 8),
            _FilterChipButton(
              label: "Završene",
              selected: selectedStatus == "Završeno",
              onTap: onTapFinished,
              selectedColor: const Color(0xFF1565C0),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? selectedColor : Colors.black.withOpacity(0.08),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF374151),
            fontWeight: FontWeight.w900,
            fontSize: 12.5,
          ),
        ),
      ),
    );
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
  final ReservationStatusUi status;
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
                    _MiniRow(
                      icon: Icons.bookmark_added_rounded,
                      text: "rezervacija poslana: $createdAtText",
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusPill(status: status),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: status.alertBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: status.alertBorder),
            ),
            child: Row(
              children: [
                Icon(
                  status.alertIcon,
                  size: 18,
                  color: status.alertFg,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status.alertText,
                    style: TextStyle(
                      fontSize: 12.7,
                      fontWeight: FontWeight.w900,
                      color: status.alertFg,
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
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final ReservationStatusUi status;

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

enum ReservationStatusUi {
  approved,
  pending,
  finished,
  unknown,
}

extension ReservationStatusMapper on ReservationStatusUi {
  static ReservationStatusUi fromString(String? status) {
    final s = (status ?? "").trim().toLowerCase();

    if (s == "odobreno") return ReservationStatusUi.approved;
    if (s == "na čekanju" || s == "na cekanju") {
      return ReservationStatusUi.pending;
    }
    if (s == "završeno" || s == "zavrseno") {
      return ReservationStatusUi.finished;
    }

    return ReservationStatusUi.unknown;
  }

  String get label {
    switch (this) {
      case ReservationStatusUi.approved:
        return "Odobreno";
      case ReservationStatusUi.pending:
        return "Na čekanju";
      case ReservationStatusUi.finished:
        return "Završeno";
      case ReservationStatusUi.unknown:
        return "Nepoznato";
    }
  }

  Color get color {
    switch (this) {
      case ReservationStatusUi.approved:
        return Colors.green;
      case ReservationStatusUi.pending:
        return Colors.orange;
      case ReservationStatusUi.finished:
        return Colors.blue;
      case ReservationStatusUi.unknown:
        return Colors.grey;
    }
  }

  Color get alertBg {
    switch (this) {
      case ReservationStatusUi.approved:
        return const Color(0xFFEAF6E5);
      case ReservationStatusUi.pending:
        return const Color(0xFFFFF3E0);
      case ReservationStatusUi.finished:
        return const Color(0xFFE3F2FD);
      case ReservationStatusUi.unknown:
        return const Color(0xFFF3F4F6);
    }
  }

  Color get alertBorder {
    switch (this) {
      case ReservationStatusUi.approved:
        return const Color(0xFFBFE6B2);
      case ReservationStatusUi.pending:
        return const Color(0xFFFFD59A);
      case ReservationStatusUi.finished:
        return const Color(0xFF90CAF9);
      case ReservationStatusUi.unknown:
        return const Color(0xFFD1D5DB);
    }
  }

  Color get alertFg {
    switch (this) {
      case ReservationStatusUi.approved:
        return const Color(0xFF2E7D32);
      case ReservationStatusUi.pending:
        return const Color(0xFFEF6C00);
      case ReservationStatusUi.finished:
        return const Color(0xFF1565C0);
      case ReservationStatusUi.unknown:
        return const Color(0xFF6B7280);
    }
  }

  IconData get alertIcon {
    switch (this) {
      case ReservationStatusUi.approved:
        return Icons.check_circle_rounded;
      case ReservationStatusUi.pending:
        return Icons.hourglass_bottom_rounded;
      case ReservationStatusUi.finished:
        return Icons.task_alt_rounded;
      case ReservationStatusUi.unknown:
        return Icons.info_outline_rounded;
    }
  }

  String get alertText {
    switch (this) {
      case ReservationStatusUi.approved:
        return "Rezervacija je odobrena.";
      case ReservationStatusUi.pending:
        return "Rezervacija je na čekanju.";
      case ReservationStatusUi.finished:
        return "Rezervacija je završena.";
      case ReservationStatusUi.unknown:
        return "Status rezervacije nije poznat.";
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
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: onClear,
                  ),
          ),
        ),
      ),
    );
  }
}