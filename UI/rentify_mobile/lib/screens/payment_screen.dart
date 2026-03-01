import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rentify_mobile/screens/base_screen.dart';
import 'package:rentify_mobile/screens/payment_list_screen.dart';
import 'package:rentify_mobile/screens/payment_preview_screen.dart';
import 'package:rentify_mobile/utils/session.dart';
import 'package:rentify_mobile/models/search_result.dart';
import 'package:rentify_mobile/helper/univerzal_pagging_helper.dart';

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

class _PaymentScreenState extends State<PaymentScreen> {
  late ReservationProvider _reservationProvider;
  late PropertyProvider _propertyProvider;
  late PaymentProvider _paymentProvider;

  late UniversalPagingProvider<Reservation> _reservationPaging;

  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  Map<int, Property> _propertiesMap = {};
  Map<int, Payment?> _lastPaymentByPropertyId = {};

  bool _metaLoading = false;
  String? _metaError;

  @override
  void initState() {
    super.initState();

    _reservationProvider = context.read<ReservationProvider>();
    _propertyProvider = context.read<PropertyProvider>();
    _paymentProvider = context.read<PaymentProvider>();

    _reservationPaging = UniversalPagingProvider<Reservation>(
      pageSize: 5,
      fetcher: ({
        required int page,
        required int pageSize,
        String? filter,
        Map<String, dynamic>? extra,
        bool includeTotalCount = true,
      }) async {
        final userId = Session.userId;
        if (userId == null) {
          return SearchResult<Reservation>()
            ..items = []
            ..totalCount = 0;
        }

        final f = <String, dynamic>{
          "userId": userId,
          "isApproved": true,
          "page": page,
          "pageSize": pageSize,
          "includeTotalCount": includeTotalCount,
          if (filter != null && filter.trim().isNotEmpty) "FTS": filter.trim(),
        };

        return await _reservationProvider.get(filter: f);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshWithMeta();
    });
  }

  Future<void> _refreshWithMeta() async {
    await _reservationPaging.refresh();
    if (!mounted) return;
    await _loadAuxForCurrentPage();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      await _reservationPaging.search(value);
      if (!mounted) return;
      await _loadAuxForCurrentPage();
    });
  }

  Future<void> _loadAuxForCurrentPage() async {
    setState(() {
      _metaLoading = true;
      _metaError = null;
    });

    try {
      final reservations = _reservationPaging.items;

      // properties for current page
      final Map<int, Property> loadedProperties = {};
      for (final r in reservations) {
        if (!loadedProperties.containsKey(r.propertyId)) {
          final p = await _propertyProvider.getById(r.propertyId);
          loadedProperties[r.propertyId] = p;
        }
      }

      // load payments for user (retrieveAll)
      final userId = Session.userId;
      if (userId == null) throw Exception("Nema userId u sesiji.");

      final paymentResult = await _paymentProvider.get(
        filter: {
          "userId": userId,
          "retrieveAll": true,
          "includeTotalCount": false,
        },
      );

      final payments = paymentResult.items;

      // last payment per propertyId
      final Map<int, Payment?> lastMap = {};
      for (final r in reservations) {
        final pid = r.propertyId;
        final list = payments.where((p) => p.propertyId == pid).toList();
        list.sort((a, b) => b.id.compareTo(a.id));
        lastMap[pid] = list.isNotEmpty ? list.first : null;
      }

      if (!mounted) return;
      setState(() {
        _propertiesMap = loadedProperties;
        _lastPaymentByPropertyId = lastMap;
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
    final paging = _reservationPaging;
    final reservations = paging.items;

    return BaseMobileScreen(
      title: "Plaćanja",
      NameAndSurname: (Session.username ?? "").trim(),
      userUsername: Session.username ?? "Nepoznato",
      onLogout: () {
        Session.odjava();
        // ti ovdje već radiš logout flow u app-u, ostavi kako ti je
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
                await _reservationPaging.search("");
                if (!mounted) return;
                await _loadAuxForCurrentPage();
                setState(() {});
              },
            ),
            Expanded(
              child: (_metaLoading && reservations.isEmpty)
                  ? const Center(child: CircularProgressIndicator())
                  : (_metaError != null && reservations.isEmpty)
                      ? _ErrorState(message: _metaError!, onRetry: _refreshWithMeta)
                      : reservations.isEmpty
                          ? const _EmptyState()
                          : RefreshIndicator(
                              onRefresh: _refreshWithMeta,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                                itemCount: reservations.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == reservations.length) {
                                    return _PagingFooter(
                                      paging: paging,
                                      onPrev: () async {
                                        await paging.previousPage();
                                        if (!mounted) return;
                                        await _loadAuxForCurrentPage();
                                      },
                                      onNext: () async {
                                        await paging.nextPage();
                                        if (!mounted) return;
                                        await _loadAuxForCurrentPage();
                                      },
                                    );
                                  }

                                  final r = reservations[index];
                                  final property = _propertiesMap[r.propertyId];
                                  final payment = _lastPaymentByPropertyId[r.propertyId];

                                  return _PaymentCard(
                                    propertyName: property?.name ?? "Učitavanje...",
                                    isMonthly: r.isMonthly == true,
                                    start: r.startDateOfRenting,
                                    end: r.endDateOfRenting,
                                    payment: payment,
                                    onOpen: property == null
                                        ? null
                                        : () async {
                                            if (r.isMonthly == true) {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => PaymentListScreen(property: property),
                                                ),
                                              );
                                              await _refreshWithMeta();
                                              return;
                                            }

                                            // short stay
                                            if (payment == null) {
                                              _snack("Još nema kreiranog zahtjeva za ovu rezervaciju.");
                                              return;
                                            }

                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PaymentPreviewScreen(
                                                  payment: payment,
                                                  property: property,
                                                  isMonthly: false,
                                                ),
                                              ),
                                            );

                                            await _refreshWithMeta();
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

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _reservationPaging.dispose();
    super.dispose();
  }
}

/// ---------------- UI pieces ----------------

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
            hintText: "Pretraga (naziv nekretnine / period...)",
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

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.propertyName,
    required this.isMonthly,
    required this.start,
    required this.end,
    required this.payment,
    required this.onOpen,
  });

  final String propertyName;
  final bool isMonthly;
  final DateTime? start;
  final DateTime? end;
  final Payment? payment;
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
    final isPayed = payment?.isPayed == true;

    final typeText = isMonthly ? "Najamnina" : "Kratki boravak";
    final cta = isMonthly ? "Lista plaćanja" : (hasPayment ? "Pregled zahtjeva" : "Nema zahtjeva");

    final enabled = isMonthly ? true : hasPayment;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                if (!isMonthly && hasPayment) _StatusChip(isPayed: isPayed),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.category_rounded, label: "Vrsta", value: typeText),
            _InfoRow(icon: Icons.event_available_rounded, label: "Početak", value: _fmt(start)),
            _InfoRow(icon: Icons.event_busy_rounded, label: "Kraj", value: _fmt(end)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(isMonthly ? Icons.payments_rounded : Icons.visibility_rounded, size: 18),
                  label: Text(cta, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

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
  const _StatusChip({required this.isPayed});
  final bool isPayed;

  @override
  Widget build(BuildContext context) {
    final bg = isPayed ? Colors.green : Colors.orange;
    final text = isPayed ? "Uplaćeno" : "Na čekanju";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _PagingFooter extends StatelessWidget {
  const _PagingFooter({
    required this.paging,
    required this.onPrev,
    required this.onNext,
  });

  final UniversalPagingProvider paging;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final totalPages = ((paging.totalCount + paging.pageSize - 1) ~/ paging.pageSize);
    final current = paging.page + 1;
    final displayTotal = totalPages == 0 ? 1 : totalPages;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: paging.hasPreviousPage ? onPrev : null, icon: const Icon(Icons.arrow_back)),
          Text("$current / $displayTotal", style: const TextStyle(fontWeight: FontWeight.w800)),
          IconButton(onPressed: paging.hasNextPage ? onNext : null, icon: const Icon(Icons.arrow_forward)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Text(
          "Trenutno nema rezervacija za prikaz.",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800),
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
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            ElevatedButton(onPressed: onRetry, child: const Text("Pokušaj ponovo")),
          ],
        ),
      ),
    );
  }
}