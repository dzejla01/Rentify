import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/helper/date_helper.dart';
import 'package:rentify_desktop/models/payment.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/reservation.dart';
import 'package:rentify_desktop/models/user.dart';
import 'package:rentify_desktop/providers/payment_provider.dart';
import 'package:rentify_desktop/providers/property_provider.dart';
import 'package:rentify_desktop/providers/reservation_provider.dart';
import 'package:rentify_desktop/screens/adding_payment_screen.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/screens/editing_payment_screen.dart';
import 'package:rentify_desktop/screens/payment_list_screen.dart';
import 'package:rentify_desktop/utils/session.dart';

enum ReservationViewFilter { active, inactive }

class PaymentUserScreen extends StatefulWidget {
  final User user;

  const PaymentUserScreen({super.key, required this.user});

  @override
  State<PaymentUserScreen> createState() => _PaymentUserScreenState();
}

class _PaymentUserScreenState extends State<PaymentUserScreen> {
  late final PropertyProvider _propertyProvider;
  late final ReservationProvider _reservationProvider;
  late final PaymentProvider _paymentProvider;

  final TextEditingController _searchCtrl = TextEditingController();

  List<Reservation> _allReservations = [];
  List<Reservation> _filteredReservations = [];

  Map<int, Property> _propertiesMap = {};
  Map<int, List<Payment>> _paymentsByReservationId = {};

  bool _isLoading = true;
  String? _loadError;

  ReservationViewFilter _selectedFilter = ReservationViewFilter.active;

  @override
  void initState() {
    super.initState();

    _reservationProvider = Provider.of<ReservationProvider>(
      context,
      listen: false,
    );
    _propertyProvider = Provider.of<PropertyProvider>(
      context,
      listen: false,
    );
    _paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    _searchCtrl.addListener(_applySearch);
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applySearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final propertiesResult = await _propertyProvider.get(
        filter: {
          "userId": Session.userId,
          "retrieveAll": true,
          "page": 0,
          "pageSize": 1000,
          "includeTotalCount": false,
        },
      );

      final ownerPropertyIds = propertiesResult.items.map((p) => p.id).toSet();

      final reservationResult = await _reservationProvider.get(
        filter: {
          "userId": widget.user.id,
          "retrieveAll": true,
          "page": 0,
          "pageSize": 1000,
          "includeTotalCount": false,
        },
      );

      final relevantReservations = reservationResult.items.where((r) {
        final status = (r.status!).trim();
        if (status == "Odbijeno") return false;
        return ownerPropertyIds.contains(r.propertyId);
      }).toList();

      final propertiesMap = <int, Property>{};
      for (final property in propertiesResult.items) {
        propertiesMap[property.id] = property;
      }

      final paymentResult = await _paymentProvider.get(
        filter: {
          "userId": widget.user.id,
          "retrieveAll": true,
          "page": 0,
          "pageSize": 1000,
          "includeTotalCount": false,
        },
      );

      final paymentsByReservationId = <int, List<Payment>>{};
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

      relevantReservations.sort((a, b) {
        final propertyA = propertiesMap[a.propertyId]?.name.toLowerCase() ?? "";
        final propertyB = propertiesMap[b.propertyId]?.name.toLowerCase() ?? "";

        final byProperty = propertyA.compareTo(propertyB);
        if (byProperty != 0) return byProperty;

        final aStart = a.startDateOfRenting ?? DateTime(1900);
        final bStart = b.startDateOfRenting ?? DateTime(1900);
        return bStart.compareTo(aStart);
      });

      if (!mounted) return;

      setState(() {
        _allReservations = relevantReservations;
        _filteredReservations = relevantReservations;
        _propertiesMap = propertiesMap;
        _paymentsByReservationId = paymentsByReservationId;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = "Greška pri učitavanju rezervacija i uplata.";
      });
    }
  }

  void _applySearch() {
    final query = _searchCtrl.text.trim().toLowerCase();

    final filtered = _allReservations.where((reservation) {
      final property = _propertiesMap[reservation.propertyId];
      final propertyName = (property?.name ?? "").toLowerCase();
      final reservationType =
          reservation.isMonthly == true ? "najamnina" : "kratki boravak";
      final status = reservation.status!.toLowerCase();

      return propertyName.contains(query) ||
          reservationType.contains(query) ||
          status.contains(query);
    }).toList();

    setState(() {
      _filteredReservations = filtered;
    });
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

    return latestPayment.paymentStatus == "Neplaćeno";
  }

  bool _hasShortStayUnpaid(Reservation reservation) {
    if (reservation.isMonthly == true) return false;

    final latestPayment = _getLatestPaymentForReservation(reservation.id);
    if (latestPayment == null) return false;

    return latestPayment.paymentStatus == "Neplaćeno";
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

  List<Reservation> _visibleReservations() {
    if (_selectedFilter == ReservationViewFilter.active) {
      return _filteredReservations.where((r) => r.status == "Odobreno").toList();
    }

    return _filteredReservations
        .where((r) => r.status == "Završeno" || r.status == "Otkazano")
        .toList();
  }

  Widget _buildFilterChips() {
  final activeCount =
      _filteredReservations.where((r) => r.status == "Odobreno").length;

  final inactiveCount = _filteredReservations
      .where((r) => r.status == "Završeno" || r.status == "Otkazano")
      .length;

  Widget buildItem({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Color selectedColor,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : const Color(0xFF4B5563),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  return Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.black.withOpacity(0.06)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 18,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        buildItem(
          label: "Aktivne ($activeCount)",
          selected: _selectedFilter == ReservationViewFilter.active,
          selectedColor: const Color(0xFF5F9F3B),
          onTap: () {
            setState(() {
              _selectedFilter = ReservationViewFilter.active;
            });
          },
        ),
        const SizedBox(width: 6),
        buildItem(
          label: "Neaktivne ($inactiveCount)",
          selected: _selectedFilter == ReservationViewFilter.inactive,
          selectedColor: const Color(0xFF4B5563),
          onTap: () {
            setState(() {
              _selectedFilter = ReservationViewFilter.inactive;
            });
          },
        ),
      ],
    ),
  );
}

  Widget _infoRow({
    required IconData icon,
    required String label,
    String? value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF5F9F3B)),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "Nepoznato",
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2A1F),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(Reservation reservation) {
    Color bg;
    if (reservation.status == "Odobreno") {
      bg = const Color(0xFF5F9F3B);
    } else if (reservation.status == "Završeno") {
      bg = const Color(0xFF4B5563);
    } else if (reservation.status == "Otkazano") {
      bg = const Color(0xFF9CA3AF);
    } else {
      bg = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        reservation.status!,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }

  Widget _warningBanner(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE53935), width: 1.2),
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

  Widget _buildActionButton({
    required Reservation reservation,
    required Property? property,
  }) {
    final latestPayment = _getLatestPaymentForReservation(reservation.id);

    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF5F9F3B),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    if (reservation.isMonthly == true) {
      return ElevatedButton.icon(
        onPressed: property == null
            ? null
            : () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PaymentListScreen(
                      user: widget.user,
                      property: property,
                      reservation: reservation,
                    ),
                  ),
                );

                await _loadData();
              },
        style: style,
        icon: const Icon(Icons.payments_rounded, size: 18),
        label: const Text(
          "Lista plaćanja",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    if (latestPayment != null) {
      return ElevatedButton.icon(
        onPressed: property == null
            ? null
            : () async {
                final refreshed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentEditingScreen(
                      user: widget.user,
                      property: property,
                      payment: latestPayment,
                      isMonthly: false,
                    ),
                  ),
                );

                if (refreshed == true && mounted) {
                  await _loadData();
                }
              },
        style: style,
        icon: const Icon(Icons.visibility_rounded, size: 18),
        label: const Text(
          "Pregled zahtjeva",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: property == null
          ? null
          : () async {
              final refreshed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentAddingScreen(
                    user: widget.user,
                    property: property,
                    billMonth: DateTime.now().month,
                    billYear: DateTime.now().year,
                    isMonthly: false,
                    reservation: reservation,
                  ),
                ),
              );

              if (refreshed == true && mounted) {
                await _loadData();
              }
            },
      style: style,
      icon: const Icon(Icons.send_rounded, size: 18),
      label: const Text(
        "Pošalji zahtjev",
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    final property = _propertiesMap[reservation.propertyId];
    final propertyName = property?.name ?? "Učitavanje...";
    final shouldHighlight = _shouldHighlightInRed(reservation);
    final warningText = _warningText(reservation);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: shouldHighlight
              ? const Color(0xFFE53935)
              : Colors.black.withOpacity(0.05),
          width: shouldHighlight ? 2 : 1,
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
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF6E5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          size: 18,
                          color: Color(0xFF5F9F3B),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          propertyName,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2A1F),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _statusChip(reservation),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(
              icon: Icons.category_rounded,
              label: "Vrsta rezervacije",
              value: reservation.isMonthly == true
                  ? "Najamnina"
                  : "Kratki boravak",
            ),
            if (reservation.startDateOfRenting != null)
              _infoRow(
                icon: Icons.event_available_rounded,
                label: "Datum početka",
                value: DateHelper.formatNullable(reservation.startDateOfRenting),
              ),
            if (reservation.endDateOfRenting != null)
              _infoRow(
                icon: Icons.event_busy_rounded,
                label: "Datum kraja",
                value: DateHelper.formatNullable(reservation.endDateOfRenting),
              ),
            if (warningText != null) _warningBanner(warningText),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: _buildActionButton(
                reservation: reservation,
                property: property,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleReservations = _visibleReservations();

    return RentifyBasePage(
      title: "Stanje uplata: ${widget.user.firstName} ${widget.user.lastName}",
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText:
                    "Pretraga (npr. naziv nekretnine, status, vrsta rezervacije)",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildFilterChips(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _loadError != null
                      ? Center(
                          child: Text(
                            _loadError!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : visibleReservations.isEmpty
                          ? Center(
                              child: Text(
                                _selectedFilter == ReservationViewFilter.active
                                    ? "Nema aktivnih rezervacija za ovog korisnika."
                                    : "Nema neaktivnih rezervacija za ovog korisnika.",
                              ),
                            )
                          : ListView.builder(
                              itemCount: visibleReservations.length,
                              itemBuilder: (context, index) {
                                final reservation = visibleReservations[index];
                                return _buildReservationCard(reservation);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}