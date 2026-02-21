import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/helper/date_helper.dart';
import 'package:rentify_desktop/helper/text_editing_controller_helper.dart';
import 'package:rentify_desktop/models/payment.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/search_result.dart';
import 'package:rentify_desktop/models/user.dart';
import 'package:rentify_desktop/providers/payment_provider.dart';
import 'package:rentify_desktop/screens/adding_payment_screen.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/screens/editing_payment_screen.dart';
import 'package:rentify_desktop/widgets/pagging_control_widget.dart';
import 'package:rentify_desktop/helper/univerzal_pagging_helper.dart';

class PaymentListScreen extends StatefulWidget {
  final User user;
  final Property property;

  const PaymentListScreen({
    super.key,
    required this.user,
    required this.property,
  });

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  late PaymentProvider _paymentProvider;

  late UniversalPagingProvider<Payment> _paging;

  final _searchCtrl = TextEditingController();
  String _searchValue = "";

  bool _metaLoading = true;
  String? _metaError;
  List<Payment> _allPayments = [];

  bool get _hasPending => _allPayments.any((p) => p.isPayed != true);

  @override
  void initState() {
    super.initState();
    _paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    _paging = UniversalPagingProvider<Payment>(
      pageSize: 5,
      fetcher:
          ({
            required int page,
            required int pageSize,
            String? filter,
            bool includeTotalCount = true,
          }) async {
            final f = <String, dynamic>{
              "userId": widget.user.id,
              "propertyId": widget.property.id,
              "page": page,
              "pageSize": pageSize,
              "includeTotalCount": includeTotalCount,

              if (filter != null && filter.trim().isNotEmpty)
                "FTS": filter.trim(),
            };

            final SearchResult<Payment> res = await _paymentProvider.get(
              filter: f,
            );
            return res;
          },
    );

    _loadAllMeta();
    _paging.loadPage();

    _searchCtrl.addListener(() {
      final v = _searchCtrl.text;
      if (v == _searchValue) return;
      _searchValue = v;
      _paging.search(v);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAllMeta() async {
    setState(() {
      _metaLoading = true;
      _metaError = null;
    });

    try {
      final res = await _paymentProvider.get(
        filter: {
          "userId": widget.user.id,
          "propertyId": widget.property.id,
          "retrieveAll": true,
          "includeTotalCount": false,
        },
      );

      final items = res.items;

      items.sort((a, b) {
        final y = b.yearNumber.compareTo(a.yearNumber);
        if (y != 0) return y;
        final m = b.monthNumber.compareTo(a.monthNumber);
        if (m != 0) return m;
        return b.id.compareTo(a.id);
      });

      setState(() {
        _allPayments = items;
        _metaLoading = false;
      });
    } catch (e) {
      setState(() {
        _metaError = e.toString();
        _metaLoading = false;
      });
    }
  }

  Payment? _lastPaidPayment() {
    final paid = _allPayments.where((p) => p.isPayed == true).toList();
    if (paid.isEmpty) return null;

    paid.sort((a, b) {
      final y = b.yearNumber.compareTo(a.yearNumber);
      if (y != 0) return y;
      final m = b.monthNumber.compareTo(a.monthNumber);
      if (m != 0) return m;
      return b.id.compareTo(a.id);
    });

    return paid.first;
  }

  (int month, int year) _nextMonthYear(int month, int year) {
    if (month == 12) return (1, year + 1);
    return (month + 1, year);
  }

  (int month, int year) _nextBillPeriod() {
    final lastPaid = _lastPaidPayment();
    if (lastPaid == null) {
      final now = DateTime.now();
      return (now.month, now.year);
    }
    return _nextMonthYear(lastPaid.monthNumber, lastPaid.yearNumber);
  }

  bool _isPeriodStarted(int month, int year) {
    final now = DateTime.now();
    final startOfPeriod = DateTime(year, month, 1);
    final startOfCurrentMonth = DateTime(now.year, now.month, 1);
    return !startOfCurrentMonth.isBefore(startOfPeriod);
  }

  bool _canSendForNextPeriod() {
    if (_hasPending) return false;
    final next = _nextBillPeriod();
    return _isPeriodStarted(next.$1, next.$2);
  }

  Widget _statusChip(bool isPayed) {
  final color = isPayed ? Colors.green : Colors.orange;
  final text = isPayed ? "Uplaćeno" : "Na čekanju";

  return Text(
    text,
    style: TextStyle(
      color: color,
      fontWeight: FontWeight.w600,
    ),
  );
}


  String _periodText(Payment p) {
    if (p.monthNumber == 0 && p.yearNumber == 0) return "-";
    return "${p.monthNumber.toString().padLeft(2, '0')}.${p.yearNumber}";
  }

  Future<void> _refreshAll() async {
    await _loadAllMeta();
    await _paging.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextBillPeriod();
    final canSend =
        !_metaLoading && _metaError == null && _canSendForNextPeriod();

    return RentifyBasePage(
      title: "Lista plaćanja: ${widget.user.firstName} ${widget.user.lastName}",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Nekretnina: ${widget.property.name}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: canSend
                          ? () async {
                              final prevPaid = _lastPaidPayment();
                              final next = _nextBillPeriod();

                              final refreshed = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentAddingScreen(
                                    user: widget.user,
                                    property: widget.property,
                                    billMonth: next.$1,
                                    billYear: next.$2,
                                    isMonthly: true,
                                    previousPayment: prevPaid,
                                  ),
                                ),
                              );

                              if (refreshed == true && mounted) {
                                await _refreshAll();
                              }
                            }
                          : null,
                      icon: const Icon(Icons.send),
                      label: const Text("Pošalji zahtjev"),
                    ),

                    if (!canSend)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _metaLoading
                              ? "Učitavam stanje uplata..."
                              : (_metaError != null
                                    ? "Ne mogu učitati podatke."
                                    : (_hasPending
                                          ? "Postoji uplata na čekanju."
                                          : "Zahtjev za ${next.$1.toString().padLeft(2, '0')}.${next.$2} možeš poslati od 01.${next.$1.toString().padLeft(2, '0')}.${next.$2}.")),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: 450,
              height: 50,
              child: TextField(
                controller: _searchCtrl,
                onChanged: (value) {
                  setState(() {}); 
                  _paging.search(value); 
                },
                decoration: InputDecoration(
                  hintText: "Pretraga (naziv/period)...",
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: PaginatedTable<Payment>(
                provider: _paging,
                header: const [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Period",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      "Naziv",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Iznos",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Status",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Rok plaćanja",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      "Akcije",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                rowBuilder: (p) {
                  final isPayed = p.isPayed == true;

                  return [
                    Expanded(flex: 2, child: Text(_periodText(p))),
                    Expanded(
                      flex: 4,
                      child: Text(
                        p.name ?? "-",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(flex: 2, child: Text("${p.price ?? 0} KM")),
                    Expanded(flex: 2, child: _statusChip(isPayed)),
                    Expanded(
                      flex: 3,
                      child: Text(
                        p.dateToPay == null
                            ? "-"
                            : DateHelper.formatNullable(p.dateToPay)!,
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () async {
                          final refreshed = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentEditingScreen(
                                user: widget.user,
                                property: widget.property,
                                payment: p,
                                isMonthly: true,
                              ),
                            ),
                          );

                          if (refreshed == true && mounted) {
                            await _refreshAll();
                          }
                        },
                        child: const Text("Pregled"),
                      ),
                    ),
                  ];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
