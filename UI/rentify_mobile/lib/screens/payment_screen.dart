import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/providers/auth_provider.dart';
import 'package:rentify_mobile/providers/device_token_provider.dart';
import 'package:rentify_mobile/routes/app_routes.dart';
import 'package:rentify_mobile/screens/base_screen.dart';
import 'package:rentify_mobile/screens/payment_list_screen.dart';
import 'package:rentify_mobile/screens/payment_preview_screen.dart';
import 'package:rentify_mobile/utils/session.dart';
import 'package:rentify_mobile/models/reservation.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/models/payment.dart';
import 'package:rentify_mobile/providers/reservation_provider.dart';
import 'package:rentify_mobile/providers/property_provider.dart';
import 'package:rentify_mobile/providers/payment_provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

enum _PaymentTab {
  active,
  inactive,
}

class _PaymentScreenState extends State<PaymentScreen> {
  late ReservationProvider _reservationProvider;
  late PropertyProvider _propertyProvider;
  late PaymentProvider _paymentProvider;

  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<Reservation> _allReservations = [];
  List<Reservation> _filteredReservations = [];

  Map<int, Property> _propertiesMap = {};
  Map<int, List<Payment>> _paymentsByReservationId = {};

  bool _isLoading = true;
  String? _loadError;

  _PaymentTab _selectedTab = _PaymentTab.active;

  @override
  void initState() {
    super.initState();

    _reservationProvider = context.read<ReservationProvider>();
    _propertyProvider = context.read<PropertyProvider>();
    _paymentProvider = context.read<PaymentProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final userId = Session.userId;
      if (userId == null) {
        throw Exception("Nema userId u sesiji.");
      }

      final reservationResult = await _reservationProvider.get(
        filter: {
          "userId": userId,
          "retrieveAll": true,
          "page": 0,
          "pageSize": 1000,
          "includeTotalCount": false,
        },
      );

      final reservations = reservationResult.items.where((r) {
        return r.statusId != 4;
      }).toList();

      final Map<int, Property> loadedProperties = {};
      for (final r in reservations) {
        if (!loadedProperties.containsKey(r.propertyId)) {
          final p = await _propertyProvider.getById(r.propertyId);
          loadedProperties[r.propertyId] = p;
        }
      }

      final paymentResult = await _paymentProvider.get(
        filter: {
          "userId": userId,
          "retrieveAll": true,
          "page": 0,
          "pageSize": 1000,
          "includeTotalCount": false,
        },
      );

      final Map<int, List<Payment>> paymentsByReservationId = {};
      for (final payment in paymentResult.items) {
        final reservationId = payment.reservation?.id;
        if (reservationId == null) continue;

        paymentsByReservationId.putIfAbsent(reservationId, () => []);
        paymentsByReservationId[reservationId]!.add(payment);
      }

      for (final entry in paymentsByReservationId.entries) {
        entry.value.sort((a, b) {
          final aDate = a.dateToPay ?? DateTime(1900);
          final bDate = b.dateToPay ?? DateTime(1900);

          final byDate = bDate.compareTo(aDate);
          if (byDate != 0) return byDate;

          return b.id.compareTo(a.id);
        });
      }

      reservations.sort((a, b) {
        final propertyA = loadedProperties[a.propertyId]?.name.toLowerCase() ?? "";
        final propertyB = loadedProperties[b.propertyId]?.name.toLowerCase() ?? "";

        final byProperty = propertyA.compareTo(propertyB);
        if (byProperty != 0) return byProperty;

        final aStart = a.startDateOfRenting ?? DateTime(1900);
        final bStart = b.startDateOfRenting ?? DateTime(1900);
        return bStart.compareTo(aStart);
      });

      if (!mounted) return;

      setState(() {
        _allReservations = reservations;
        _filteredReservations = reservations;
        _propertiesMap = loadedProperties;
        _paymentsByReservationId = paymentsByReservationId;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _applySearch);
  }

  void _applySearch() {
    final query = _searchCtrl.text.trim().toLowerCase();

    final filtered = _allReservations.where((reservation) {
      final property = _propertiesMap[reservation.propertyId];
      final propertyName = (property?.name ?? "").toLowerCase();
      final reservationType =
          reservation.isMonthly == true ? "najamnina" : "kratki boravak";
      final reservationStatus = (reservation.status?.name ?? "").toLowerCase();

      final latestPayment = _getLatestPaymentForReservation(reservation.id);
      final paymentStatus = (latestPayment?.status?.name ?? "").toLowerCase();

      return propertyName.contains(query) ||
          reservationType.contains(query) ||
          reservationStatus.contains(query) ||
          paymentStatus.contains(query);
    }).toList();

    if (!mounted) return;
    setState(() {
      _filteredReservations = filtered;
    });
  }

  Future<void> _changeTab(_PaymentTab tab) async {
    if (_selectedTab == tab) return;
    setState(() {
      _selectedTab = tab;
    });
  }

  List<Reservation> _visibleReservations() {
    if (_selectedTab == _PaymentTab.active) {
      return _filteredReservations.where((r) => r.statusId == 2).toList();
    }

    return _filteredReservations
        .where((r) => r.statusId == 3 || r.statusId == 5)
        .toList();
  }

  Payment? _getLatestPaymentForReservation(int reservationId) {
    final payments = _paymentsByReservationId[reservationId];
    if (payments == null || payments.isEmpty) return null;
    return payments.first;
  }

  bool _hasMonthlyUnpaidLastInstallment(Reservation reservation) {
    if (reservation.isMonthly != true) return false;

    final latestPayment = _getLatestPaymentForReservation(reservation.id);
    if (latestPayment == null) return false;

    return latestPayment.statusId == 8;
  }

  bool _hasShortStayUnpaid(Reservation reservation) {
    if (reservation.isMonthly == true) return false;

    final latestPayment = _getLatestPaymentForReservation(reservation.id);
    if (latestPayment == null) return false;

    return latestPayment.statusId == 8;
  }

  bool _shouldHighlightInRed(Reservation reservation) {
    if (reservation.isMonthly == true) {
      return _hasMonthlyUnpaidLastInstallment(reservation);
    }
    return _hasShortStayUnpaid(reservation);
  }

  String? _warningText(Reservation reservation) {
    if (reservation.isMonthly == true &&
        _hasMonthlyUnpaidLastInstallment(reservation)) {
      return "Zadnja poslana rata je neplaćena.";
    }

    if (reservation.isMonthly != true && _hasShortStayUnpaid(reservation)) {
      return "Boravak je neplaćen.";
    }

    return null;
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reservations = _visibleReservations();

    return BaseMobileScreen(
      title: "Plaćanja",
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
              onClear: () {
                _searchCtrl.clear();
                _applySearch();
                setState(() {});
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: "Aktivne",
                      selected: _selectedTab == _PaymentTab.active,
                      onTap: () => _changeTab(_PaymentTab.active),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TabButton(
                      label: "Neaktivne",
                      selected: _selectedTab == _PaymentTab.inactive,
                      onTap: () => _changeTab(_PaymentTab.inactive),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_loadError != null)
                      ? _ErrorState(
                          message: _loadError!,
                          onRetry: _loadData,
                        )
                      : reservations.isEmpty
                          ? _EmptyState(
                              text: _selectedTab == _PaymentTab.active
                                  ? "Trenutno nema aktivnih plaćanja za prikaz."
                                  : "Trenutno nema neaktivnih plaćanja za prikaz.",
                            )
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                                itemCount: reservations.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final r = reservations[index];
                                  final property = _propertiesMap[r.propertyId];
                                  final payment =
                                      _getLatestPaymentForReservation(r.id);

                                  return _PaymentCard(
                                    propertyName:
                                        property?.name ?? "Učitavanje...",
                                    isMonthly: r.isMonthly == true,
                                    start: r.startDateOfRenting,
                                    end: r.endDateOfRenting,
                                    reservationStatus: r.status?.name,
                                    payment: payment,
                                    warningText: _warningText(r),
                                    highlightRed: _shouldHighlightInRed(r),
                                    onOpen: property == null
                                        ? null
                                        : () async {
                                            if (r.isMonthly == true) {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      PaymentListScreen(
                                                    property: property,
                                                    reservationStatus:
                                                        r.status?.name ?? "-",
                                                  ),
                                                ),
                                              );
                                              await _loadData();
                                              return;
                                            }

                                            if (payment == null) {
                                              _snack(
                                                "Još nema kreiranog zahtjeva za ovu rezervaciju.",
                                              );
                                              return;
                                            }

                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    PaymentPreviewScreen(
                                                  payment: payment,
                                                  property: property,
                                                  isMonthly: false,
                                                ),
                                              ),
                                            );

                                            await _loadData();
                                          },
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }
}


class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

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
            hintText: "Pretraga (naziv nekretnine / status / period...)",
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

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF5F9F3B);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? green : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? green : Colors.black.withOpacity(0.08),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: green.withOpacity(0.16),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF374151),
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.propertyName,
    required this.isMonthly,
    required this.start,
    required this.end,
    required this.reservationStatus,
    required this.payment,
    required this.warningText,
    required this.highlightRed,
    required this.onOpen,
  });

  final String propertyName;
  final bool isMonthly;
  final DateTime? start;
  final DateTime? end;
  final String? reservationStatus;
  final Payment? payment;
  final String? warningText;
  final bool highlightRed;
  final VoidCallback? onOpen;

  String _fmt(DateTime? d) {
    if (d == null) return "-";
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return "$dd.$mm.$yy";
  }

  @override
  Widget build(BuildContext context) {
    final hasPayment = payment != null;

    final typeText = isMonthly ? "Najamnina" : "Kratki boravak";
    final cta = isMonthly
        ? "Lista plaćanja"
        : (hasPayment ? "Pregled zahtjeva" : "Nema zahtjeva");

    final enabled = isMonthly ? true : hasPayment;

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlightRed
              ? const Color(0xFFE53935)
              : Colors.black.withOpacity(0.05),
          width: highlightRed ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    color: Color(0xFF5F9F3B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    propertyName,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2A1F),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusChip(
                  paymentStatus: payment?.status?.name,
                  reservationStatus: reservationStatus,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.category_rounded,
              label: "Vrsta",
              value: typeText,
            ),
            _InfoRow(
              icon: Icons.event_available_rounded,
              label: "Početak",
              value: _fmt(start),
            ),
            _InfoRow(
              icon: Icons.event_busy_rounded,
              label: "Kraj",
              value: _fmt(end),
            ),
            _InfoRow(
              icon: Icons.info_outline_rounded,
              label: "Status",
              value: reservationStatus ?? "-",
            ),
            if (warningText != null) ...[
              const SizedBox(height: 12),
              _WarningBanner(text: warningText!),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: (enabled && onOpen != null) ? onOpen : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F9F3B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    isMonthly
                        ? Icons.payments_rounded
                        : Icons.visibility_rounded,
                    size: 18,
                  ),
                  label: Text(
                    cta,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF5F9F3B)),
          const SizedBox(width: 8),
          SizedBox(
            width: 86,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2A1F),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.paymentStatus,
    required this.reservationStatus,
  });

  final String? paymentStatus;
  final String? reservationStatus;

  @override
  Widget build(BuildContext context) {
    final status = (paymentStatus ?? reservationStatus ?? "Nema zahtjeva").trim();

    Color bg;
    switch (status) {
      case "Plaćeno":
        bg = Colors.green;
        break;
      case "Procesiranje":
        bg = Colors.blue;
        break;
      case "Neplaćeno":
        bg = Colors.red;
        break;
      case "Otkazano":
        bg = Colors.grey;
        break;
      case "Neuspješno":
        bg = Colors.deepOrange;
        break;
      case "Završeno":
        bg = const Color(0xFF4B5563);
        break;
      case "Odobreno":
        bg = const Color(0xFF5F9F3B);
        break;
      case "Na čekanju":
        bg = Colors.orange;
        break;
      default:
        bg = const Color(0xFF6B7280);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE53935),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFE53935),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
                fontSize: 12.8,
              ),
            ),
          ),
        ],
      ),
    );
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
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

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
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => onRetry(),
              child: const Text("Pokušaj ponovo"),
            ),
          ],
        ),
      ),
    );
  }
}