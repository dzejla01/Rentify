import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/dialogs/base_dialogs.dart';
import 'package:rentify_mobile/dialogs/confirmation_dialogs.dart';
import 'package:rentify_mobile/helper/exception_read_helper.dart';
import 'package:rentify_mobile/providers/appoitment_provider.dart';
import 'package:rentify_mobile/providers/auth_provider.dart';
import 'package:rentify_mobile/providers/device_token_provider.dart';
import 'package:rentify_mobile/routes/app_routes.dart';
import 'package:rentify_mobile/screens/base_screen.dart';
import 'package:rentify_mobile/utils/session.dart';
import 'package:rentify_mobile/models/search_result.dart';
import 'package:rentify_mobile/helper/univerzal_pagging_helper.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/models/appointment.dart';
import 'package:rentify_mobile/providers/property_provider.dart';
import 'package:rentify_mobile/widgets/swipe_widget.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  late AppoitmentProvider _appointmentProvider;
  late PropertyProvider _propertyProvider;

  late UniversalPagingProvider<Appointment> _paging;

  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  Map<int, Property> _propertiesMap = {};

  bool _metaLoading = false;
  String? _metaError;
  int? _selectedStatusId;
  int? _cancellingAppointmentId;

  @override
  void initState() {
    super.initState();

    _appointmentProvider = context.read<AppoitmentProvider>();
    _propertyProvider = context.read<PropertyProvider>();

    _paging = UniversalPagingProvider<Appointment>(
      pageSize: 7,
      fetcher: ({
        required int page,
        required int pageSize,
        String? filter,
        Map<String, dynamic>? extra,
        bool includeTotalCount = true,
      }) async {
        final userId = Session.userId;
        if (userId == null) return SearchResult<Appointment>()..totalCount = 0;

        final f = <String, dynamic>{
          "userId": userId,
          "page": page,
          "pageSize": pageSize,
          "includeTotalCount": includeTotalCount,
          if (filter != null && filter.trim().isNotEmpty) "FTS": filter.trim(),
          if (_selectedStatusId != null) "statusId": _selectedStatusId,
          ...?extra,
        };

        return await _appointmentProvider.get(filter: f);
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

  Future<void> _changeStatusFilter(int? statusId) async {
    if (!mounted) return;

    setState(() {
      _selectedStatusId = statusId;
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
      final items = _paging.items;

      final Map<int, Property> loaded = {};
      for (final a in items) {
        if (!loaded.containsKey(a.propertyId)) {
          loaded[a.propertyId] = await _propertyProvider.getById(a.propertyId);
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
        _metaError = extractErrorMessage(e);
      });
    }
  }

  Future<void> _showCancelAppointmentDialog(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return RentifyBaseDialog(
          title: "Otkaži termin",
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 54,
                color: Color(0xFFD97706),
              ),
              const SizedBox(height: 16),
              const Text(
                "Da li ste sigurni da želite otkazati ovaj termin?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.black.withOpacity(0.12)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Odustani",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Otkaži termin",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          onClose: () => Navigator.pop(context, false),
        );
      },
    );

    if (confirmed == true) {
      if (!mounted) return;
      final reason = await ConfirmDialogs.reasonPrompt(
        context,
        title: "Razlog otkazivanja",
        message: "Unesite razlog otkazivanja termina:",
      );
      if (reason == null) return;
      await _cancelAppointment(appointment, reason);
    }
  }

  Future<void> _cancelAppointment(Appointment appointment, String reason) async {
    final id = appointment.id;

    try {
      if (!mounted) return;
      setState(() => _cancellingAppointmentId = id);

      await _appointmentProvider.cancel(id, reason);
      await _refreshWithMeta();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Termin je uspješno otkazan."),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e)), backgroundColor: const Color(0xFFC62828)),
      );
    } finally {
      if (mounted) {
        setState(() => _cancellingAppointmentId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseMobileScreen(
      title: "Termini",
      NameAndSurname: Session.fullName!,
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
              hint: "Pretraga (nekretnina / datum...)",
            ),

            _StatusFilterBar(
              selectedStatusId: _selectedStatusId,
              onTapAll: () => _changeStatusFilter(null),
              onTapApproved: () => _changeStatusFilter(2),
              onTapPending: () => _changeStatusFilter(1),
              onTapFinished: () => _changeStatusFilter(3),
              onTapRejected: () => _changeStatusFilter(4),
              onTapCancelled: () => _changeStatusFilter(5),
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
                      const _EmptyState(text: "Trenutno nema termina.")
                    else ...[
                      SwipePagedList<Appointment>(
                        provider: _paging,
                        separatorHeight: 12,
                        itemBuilder: (context, a) {
                          final p = _propertiesMap[a.propertyId];
                          final status = StatusMapper.fromStatus(a.status?.name);

                          final createdAtText = _maybeCreatedAtText(a);

                          return _AppointmentCard(
                            propertyName: p?.name ?? "Učitavanje...",
                            dateTimeText: _dateTimeText(a.dateAppointment),
                            createdAtText: createdAtText,
                            status: status,
                            loadingMeta: _metaLoading && p == null,
                            showCancelButton: status == _Status.approved,
                            isCancelling: _cancellingAppointmentId == a.id,
                            onCancel: () => _showCancelAppointmentDialog(a),
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

  static String _dateTimeText(DateTime? d) {
    if (d == null) return "-";
    final local = d.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final yy = local.year.toString();
    final hh = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return "$dd.$mm.$yy • $hh:$mi";
  }

  static String _maybeCreatedAtText(Appointment a) {
    try {
      final dynamic any = a as dynamic;
      final DateTime? createdAt = any.createdAt as DateTime?;
      if (createdAt == null) return "-";
      final local = createdAt.toLocal();
      final dd = local.day.toString().padLeft(2, '0');
      final mm = local.month.toString().padLeft(2, '0');
      final yy = local.year.toString();
      final hh = local.hour.toString().padLeft(2, '0');
      final mi = local.minute.toString().padLeft(2, '0');
      return "$dd.$mm.$yy • $hh:$mi";
    } catch (_) {
      return "-";
    }
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

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({
    required this.selectedStatusId,
    required this.onTapAll,
    required this.onTapApproved,
    required this.onTapPending,
    required this.onTapFinished,
    required this.onTapRejected,
    required this.onTapCancelled,
  });

  final int? selectedStatusId;
  final VoidCallback onTapAll;
  final VoidCallback onTapApproved;
  final VoidCallback onTapPending;
  final VoidCallback onTapFinished;
  final VoidCallback onTapRejected;
  final VoidCallback onTapCancelled;

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
              selected: selectedStatusId == null,
              onTap: onTapAll,
              selectedColor: const Color(0xFF5F9F3B),
            ),
            const SizedBox(width: 8),
            _FilterChipButton(
              label: "Odobreni",
              selected: selectedStatusId == 2,
              onTap: onTapApproved,
              selectedColor: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            _FilterChipButton(
              label: "Na čekanju",
              selected: selectedStatusId == 1,
              onTap: onTapPending,
              selectedColor: const Color(0xFFEF6C00),
            ),
            const SizedBox(width: 8),
            _FilterChipButton(
              label: "Završeni",
              selected: selectedStatusId == 3,
              onTap: onTapFinished,
              selectedColor: const Color(0xFF1565C0),
            ),
            const SizedBox(width: 8),
            _FilterChipButton(
              label: "Odbijeni",
              selected: selectedStatusId == 4,
              onTap: onTapRejected,
              selectedColor: const Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            _FilterChipButton(
              label: "Otkazani",
              selected: selectedStatusId == 5,
              onTap: onTapCancelled,
              selectedColor: const Color(0xFFC62828),
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

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.propertyName,
    required this.dateTimeText,
    required this.createdAtText,
    required this.status,
    this.loadingMeta = false,
    this.showCancelButton = false,
    this.isCancelling = false,
    this.onCancel,
  });

  final String propertyName;
  final String dateTimeText;
  final String createdAtText;
  final _Status status;
  final bool loadingMeta;
  final bool showCancelButton;
  final bool isCancelling;
  final VoidCallback? onCancel;

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
                  Icons.event_available_rounded,
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
                    _MiniRow(
                      icon: Icons.schedule_rounded,
                      text: "Termin: $dateTimeText",
                    ),
                    const SizedBox(height: 6),
                    _MiniRow(
                      icon: Icons.bookmark_added_rounded,
                      text: createdAtText == "-"
                          ? "Zahtjev poslan"
                          : "Zahtjev poslan: $createdAtText",
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
              color: _alertBg(status),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _alertBorder(status)),
            ),
            child: Row(
              children: [
                Icon(_alertIcon(status), size: 18, color: _alertFg(status)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _alertText(status),
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
          if (showCancelButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isCancelling ? null : onCancel,
                icon: isCancelling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cancel_rounded),
                label: Text(
                  isCancelling ? "Otkazivanje..." : "Otkaži",
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static IconData _alertIcon(_Status s) {
    switch (s) {
      case _Status.approved:
        return Icons.check_circle_rounded;
      case _Status.pending:
        return Icons.hourglass_bottom_rounded;
      case _Status.finished:
        return Icons.task_alt_rounded;
      case _Status.rejected:
        return Icons.block_rounded;
      case _Status.cancelled:
        return Icons.cancel_rounded;
      case _Status.unknown:
        return Icons.info_outline_rounded;
    }
  }

  static String _alertText(_Status s) {
    switch (s) {
      case _Status.approved:
        return "Termin je odobren.";
      case _Status.pending:
        return "Termin je na čekanju.";
      case _Status.finished:
        return "Termin je završen.";
      case _Status.rejected:
        return "Termin je odbijen.";
      case _Status.cancelled:
        return "Termin je otkazan.";
      case _Status.unknown:
        return "Status termina nije poznat.";
    }
  }

  static Color _alertBg(_Status s) {
    switch (s) {
      case _Status.approved:
        return const Color(0xFFEAF6E5);
      case _Status.pending:
        return const Color(0xFFFFF3E0);
      case _Status.finished:
        return const Color(0xFFE3F2FD);
      case _Status.rejected:
        return const Color(0xFFF3F4F6);
      case _Status.cancelled:
        return const Color(0xFFFFEBEE);
      case _Status.unknown:
        return const Color(0xFFF3F4F6);
    }
  }

  static Color _alertBorder(_Status s) {
    switch (s) {
      case _Status.approved:
        return const Color(0xFFBFE6B2);
      case _Status.pending:
        return const Color(0xFFFFD59A);
      case _Status.finished:
        return const Color(0xFF90CAF9);
      case _Status.rejected:
        return const Color(0xFFD1D5DB);
      case _Status.cancelled:
        return const Color(0xFFFFCDD2);
      case _Status.unknown:
        return const Color(0xFFD1D5DB);
    }
  }

  static Color _alertFg(_Status s) {
    switch (s) {
      case _Status.approved:
        return const Color(0xFF2E7D32);
      case _Status.pending:
        return const Color(0xFFEF6C00);
      case _Status.finished:
        return const Color(0xFF1565C0);
      case _Status.rejected:
        return const Color(0xFF6B7280);
      case _Status.cancelled:
        return const Color(0xFFC62828);
      case _Status.unknown:
        return const Color(0xFF6B7280);
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

enum _Status {
  approved,
  pending,
  finished,
  rejected,
  cancelled,
  unknown,
}

extension StatusMapper on _Status {
  static _Status fromStatus(String? status) {
    final s = (status ?? "").trim().toLowerCase();

    if (s == "odobreno") return _Status.approved;
    if (s == "na čekanju" || s == "na cekanju") return _Status.pending;
    if (s == "završeno" || s == "zavrseno") return _Status.finished;
    if (s == "odbijeno") return _Status.rejected;
    if (s == "otkazano") return _Status.cancelled;

    return _Status.unknown;
  }

  String get label {
    switch (this) {
      case _Status.approved:
        return "Odobreno";
      case _Status.pending:
        return "Na čekanju";
      case _Status.finished:
        return "Završeno";
      case _Status.rejected:
        return "Odbijeno";
      case _Status.cancelled:
        return "Otkazano";
      case _Status.unknown:
        return "Nepoznato";
    }
  }

  Color get color {
    switch (this) {
      case _Status.approved:
        return Colors.green;
      case _Status.pending:
        return Colors.orange;
      case _Status.finished:
        return Colors.blue;
      case _Status.rejected:
        return const Color(0xFF6B7280);
      case _Status.cancelled:
        return const Color(0xFFC62828);
      case _Status.unknown:
        return Colors.grey;
    }
  }
}

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
