import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rentify_mobile/screens/base_screen.dart';
import 'package:rentify_mobile/utils/session.dart';

import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/models/payment.dart';
import 'package:rentify_mobile/models/search_result.dart';
import 'package:rentify_mobile/helper/univerzal_pagging_helper.dart';

import 'package:rentify_mobile/providers/payment_provider.dart';
import 'payment_preview_screen.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key, required this.property});

  final Property property;

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  late PaymentProvider _paymentProvider;
  late UniversalPagingProvider<Payment> _paging;

  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _paymentProvider = context.read<PaymentProvider>();

    _paging = UniversalPagingProvider<Payment>(
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
          return SearchResult<Payment>()
            ..items = []
            ..totalCount = 0;
        }

        final f = <String, dynamic>{
          "userId": userId,
          "propertyId": widget.property.id,
          "page": page,
          "pageSize": pageSize,
          "includeTotalCount": includeTotalCount,
          if (filter != null && filter.trim().isNotEmpty) "FTS": filter.trim(),
        };

        return await _paymentProvider.get(filter: f);
      },
    );

    _paging.addListener(() {
    if (mounted) setState(() {});
  });

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _paging.refresh();
  });
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _paging.search(v);
    });
  }

  String _periodText(Payment p) {
    if (p.monthNumber == 0 && p.yearNumber == 0) return "-";
    return "${p.monthNumber.toString().padLeft(2, '0')}.${p.yearNumber}";
  }

  @override
  Widget build(BuildContext context) {
    return BaseMobileScreen(
      title: "Najamnina",
      NameAndSurname: (Session.username ?? "").trim(),
      userUsername: Session.username ?? "Nepoznato",
      onLogout: () {},
      child: Container(
        color: const Color(0xFFF6F7FB),
        child: Column(
          children: [
            Padding(
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
                    )
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Pretraga (naziv / period)...",
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              _paging.search("");
                              setState(() {});
                            },
                          ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _paging.isLoading && _paging.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _paging.items.isEmpty
                      ? const Center(
                          child: Text(
                            "Nema uplata za ovu nekretninu.",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          itemCount: _paging.items.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _paging.items.length) {
                              return _PagingFooter(
                                paging: _paging,
                                onPrev: () => _paging.previousPage(),
                                onNext: () => _paging.nextPage(),
                              );
                            }

                            final p = _paging.items[index];
                            final isPayed = p.isPayed == true;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
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
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.name,
                                          style: const TextStyle(
                                            fontSize: 14.8,
                                            fontWeight: FontWeight.w900,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      _MiniStatus(isPayed: isPayed),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _Line(label: "Period", value: _periodText(p)),
                                  _Line(label: "Iznos", value: "${p.price.toStringAsFixed(2)} KM"),
                                  _Line(
                                    label: "Rok",
                                    value: p.dateToPay == null ? "-" : _fmt(p.dateToPay!),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      height: 42,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final refreshed = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PaymentPreviewScreen(
                                                payment: p,
                                                property: widget.property,
                                                isMonthly: true,
                                              ),
                                            ),
                                          );

                                          if (refreshed == true && mounted) {
                                            await _paging.refresh();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF5F9F3B),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        icon: const Icon(Icons.visibility_rounded, size: 18),
                                        label: const Text("Pregled", style: TextStyle(fontWeight: FontWeight.w800)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return "$dd.$mm.$yy";
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _paging.dispose();
    super.dispose();
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              "$label:",
              style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatus extends StatelessWidget {
  const _MiniStatus({required this.isPayed});
  final bool isPayed;

  @override
  Widget build(BuildContext context) {
    return Text(
      isPayed ? "Uplaćeno" : "Na čekanju",
      style: TextStyle(
        color: isPayed ? Colors.green : Colors.orange,
        fontWeight: FontWeight.w900,
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