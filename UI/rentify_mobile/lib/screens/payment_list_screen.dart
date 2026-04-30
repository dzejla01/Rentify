import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/providers/auth_provider.dart';
import 'package:rentify_mobile/providers/device_token_provider.dart';
import 'package:rentify_mobile/routes/app_routes.dart';
import 'package:rentify_mobile/screens/base_screen.dart';
import 'package:rentify_mobile/utils/session.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/models/payment.dart';
import 'package:rentify_mobile/models/search_result.dart';
import 'package:rentify_mobile/helper/univerzal_pagging_helper.dart';
import 'package:rentify_mobile/providers/payment_provider.dart';
import 'package:rentify_mobile/widgets/swipe_widget.dart';
import 'payment_preview_screen.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({
    super.key,
    required this.property,
    required this.reservationStatus,
  });

  final Property property;
  final String reservationStatus;

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
          "reservationStatus": widget.reservationStatus,
          "page": page,
          "pageSize": pageSize,
          "includeTotalCount": includeTotalCount,
          if (filter != null && filter.trim().isNotEmpty) "FTS": filter.trim(),
          ...?extra,
        };

        return await _paymentProvider.get(filter: f);
      },
    );

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

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isAdditionalDeadlineActive(Payment p) {
    final paymentStatus = (p.paymentStatus ?? "").trim();

    if (widget.reservationStatus == "Završeno" ||
        widget.reservationStatus == "Otkazano") {
      return false;
    }

    if (paymentStatus == "Plaćeno" ||
        paymentStatus == "Neplaćeno" ||
        paymentStatus == "Otkazano" ||
        paymentStatus == "Neuspješno") {
      return false;
    }

    if (p.dateToPay == null) return false;
    if (p.secondWarningDate == null) return false;

    final today = _dateOnly(DateTime.now());
    final dueDate = _dateOnly(p.dateToPay!);

    return !today.isBefore(dueDate);
  }

  bool _isUnpaid(Payment p) {
    return (p.paymentStatus ?? "").trim() == "Neplaćeno";
  }

  bool _shouldHighlightRed(Payment p) {
    return _isAdditionalDeadlineActive(p) || _isUnpaid(p);
  }

  String _additionalDeadlineMessage(Payment p) {
    final second = p.secondWarningDate;
    if (second != null) {
      return "Prvi rok plaćanja nije ispoštovan. Dodijeljen je dodatni rok do ${_fmt(second)}. Ako ni dodatni rok ne bude ispoštovan, zahtjev će biti završen zbog neplaćenog duga.";
    }

    return "Prvi rok plaćanja nije ispoštovan. Dodijeljen je dodatni rok za izmirenje obaveze. Ako ni dodatni rok ne bude ispoštovan, zahtjev će biti završen zbog neplaćenog duga.";
  }

  String _unpaidMessage(Payment p) {
    return "Ova rata je označena kao neplaćena.";
  }

  String _screenTitle() {
    if (widget.reservationStatus == "Odobreno") {
      return "Aktivna plaćanja";
    }

    return "Neaktivna plaćanja";
  }

  String _emptyText() {
    if (widget.reservationStatus == "Odobreno") {
      return "Trenutno nema aktivnih plaćanja za prikaz.";
    }

    return "Trenutno nema neaktivnih plaćanja za prikaz.";
  }

  @override
  Widget build(BuildContext context) {
    return BaseMobileScreen(
      title: _screenTitle(),
      NameAndSurname: Session.fullName!,
      userUsername: Session.username ?? "Nepoznato",
      userImageAsset: Session.userImage,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  controller: _searchCtrl,
                  onChanged: (v) {
                    _onSearchChanged(v);
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: "Pretraga (naziv / period / status)...",
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SwipePagedList<Payment>(
                  provider: _paging,
                  separatorHeight: 12,
                  itemBuilder: (context, p) {
                    final showAdditionalDeadline = _isAdditionalDeadlineActive(p);
                    final isUnpaid = _isUnpaid(p);
                    final paymentStatus = (p.paymentStatus ?? "").trim();

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _shouldHighlightRed(p)
                              ? const Color(0xFFE53935)
                              : Colors.black.withOpacity(0.05),
                          width: _shouldHighlightRed(p) ? 2 : 1,
                        ),
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
                          if (showAdditionalDeadline) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFFFCDD2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 1),
                                    child: Icon(
                                      Icons.warning_amber_rounded,
                                      color: Color(0xFFD32F2F),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Dodatni rok",
                                          style: TextStyle(
                                            color: Color(0xFFD32F2F),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _additionalDeadlineMessage(p),
                                          style: const TextStyle(
                                            color: Color(0xFF7F1D1D),
                                            fontWeight: FontWeight.w600,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (isUnpaid) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFFFCDD2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 1),
                                    child: Icon(
                                      Icons.error_outline_rounded,
                                      color: Color(0xFFD32F2F),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _unpaidMessage(p),
                                      style: const TextStyle(
                                        color: Color(0xFF7F1D1D),
                                        fontWeight: FontWeight.w700,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
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
                              _MiniStatus(
                                paymentStatus: paymentStatus,
                                reservationStatus: widget.reservationStatus,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _Line(label: "Period", value: _periodText(p)),
                          _Line(
                            label: "Iznos",
                            value: "${p.price.toStringAsFixed(2)} KM",
                          ),
                          _Line(
                            label: "Rok",
                            value:
                                p.dateToPay == null ? "-" : _fmt(p.dateToPay!),
                          ),
                          if (showAdditionalDeadline &&
                              p.secondWarningDate != null)
                            _Line(
                              label: "Dodatni rok",
                              value: _fmt(p.secondWarningDate!),
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.visibility_rounded,
                                  size: 18,
                                ),
                                label: const Text(
                                  "Pregled",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
            width: 84,
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w800,
              ),
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
  const _MiniStatus({
    required this.paymentStatus,
    required this.reservationStatus,
  });

  final String paymentStatus;
  final String reservationStatus;

  @override
  Widget build(BuildContext context) {
    final status = paymentStatus.isNotEmpty ? paymentStatus : reservationStatus;

    Color color;
    switch (status) {
      case "Plaćeno":
        color = Colors.green;
        break;
      case "Procesiranje":
        color = Colors.blue;
        break;
      case "Neplaćeno":
        color = Colors.red;
        break;
      case "Otkazano":
        color = Colors.grey;
        break;
      case "Neuspješno":
        color = Colors.deepOrange;
        break;
      case "Na čekanju":
        color = Colors.orange;
        break;
      case "Završeno":
        color = const Color(0xFF466F2C);
        break;
      default:
        color = const Color(0xFF6B7280);
        break;
    }

    return Text(
      status,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}