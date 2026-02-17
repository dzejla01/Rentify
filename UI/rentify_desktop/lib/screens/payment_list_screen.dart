import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/helper/date_helper.dart';
import 'package:rentify_desktop/models/payment.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/user.dart';
import 'package:rentify_desktop/providers/payment_provider.dart';
import 'package:rentify_desktop/screens/adding_payment_screen.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/screens/editing_payment_screen.dart';

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

  bool _isLoading = true;
  List<Payment> _payments = [];
  String? _error;
  bool get _hasPending => _payments.any((p) => p.isPayed != true);

  @override
  void initState() {
    super.initState();
    _paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    _loadPayments();
  }

  Payment? _lastPaidPayment() {
    final paid = _payments.where((p) => p.isPayed == true).toList();
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

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _paymentProvider.get(
        filter: {"userId": widget.user.id, "propertyId": widget.property.id},
      );

      final items = result.items;

      // Sort: newest first (year, month, then id)
      items.sort((a, b) {
        final y = (b.yearNumber).compareTo(a.yearNumber);
        if (y != 0) return y;
        final m = (b.monthNumber).compareTo(a.monthNumber);
        if (m != 0) return m;
        return (b.id).compareTo(a.id);
      });

      setState(() {
        _payments = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _statusChip(bool isPayed) {
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _periodText(Payment p) {
    // Ako month/year nisu meaningful (npr short-stay), možeš fallback:
    if (p.monthNumber == 0 && p.yearNumber == 0) return "-";
    return "${p.monthNumber.toString().padLeft(2, '0')}.${p.yearNumber}";
  }

  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: "Lista plaćanja: ${widget.user.firstName} ${widget.user.lastName}",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
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
                ElevatedButton.icon(
                  onPressed: _hasPending
                      ? null
                      : () async {
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
                            await _loadPayments();
                          }
                        },
                  icon: const Icon(Icons.send),
                  label: const Text("Pošalji zahtjev"),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text("Greška: $_error", textAlign: TextAlign.center),
                ),
              )
            else if (_payments.isEmpty)
              const Expanded(
                child: Center(child: Text("Nema plaćanja za ovu nekretninu.")),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 32,
                    ),
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 18,
                        headingRowHeight: 44,
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 64,
                        columns: const [
                          DataColumn(label: Text("Period")),
                          DataColumn(label: Text("Naziv")),
                          DataColumn(label: Text("Iznos")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Rok plaćanja")),
                          DataColumn(label: Text("Akcije")),
                        ],
                        rows: _payments.map((p) {
                          final isPayed = p.isPayed == true;

                          return DataRow(
                            cells: [
                              DataCell(Text(_periodText(p))),
                              DataCell(
                                SizedBox(
                                  width: 220,
                                  child: Text(
                                    p.name ?? "-",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(Text("${p.price ?? 0} KM")),
                              DataCell(_statusChip(isPayed)),
                              DataCell(
                                Text(
                                  p.dateToPay == null
                                      ? "-"
                                      : DateHelper.formatNullable(p.dateToPay)!,
                                ),
                              ),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PaymentEditingScreen(
                                          user: widget.user,
                                          property: widget.property,
                                          payment: p,
                                          isMonthly: true,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text("Pregled"),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
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
