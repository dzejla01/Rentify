import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/helper/date_helper.dart';
import 'package:rentify_desktop/models/payment.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/reservation.dart';
import 'package:rentify_desktop/models/user.dart';
import 'package:rentify_desktop/models/search_result.dart';
import 'package:rentify_desktop/providers/payment_provider.dart';
import 'package:rentify_desktop/providers/property_provider.dart';
import 'package:rentify_desktop/providers/reservation_provider.dart';
import 'package:rentify_desktop/screens/adding_payment_screen.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/screens/editing_payment_screen.dart';
import 'package:rentify_desktop/screens/payment_list_screen.dart';
import 'package:rentify_desktop/helper/univerzal_pagging_helper.dart'; 

class PaymentUserScreen extends StatefulWidget {
  final User user;

  const PaymentUserScreen({super.key, required this.user});

  @override
  State<PaymentUserScreen> createState() => _PaymentUserScreenState();
}

class _PaymentUserScreenState extends State<PaymentUserScreen> {
  late PropertyProvider _propertyProvider;
  late ReservationProvider _reservationProvider;
  late PaymentProvider _paymentProvider;

  late UniversalPagingProvider<Reservation> _reservationPaging;

  final _searchCtrl = TextEditingController();
  String _searchText = "";

  Map<int, Property> _propertiesMap = {};
  Map<int, Payment?> _shortStayPaymentByPropertyId = {};

  @override
  void initState() {
    super.initState();

    _reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
    _propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    _paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    _reservationPaging = UniversalPagingProvider<Reservation>(
      pageSize: 5,
      fetcher: ({
        required int page,
        required int pageSize,
        String? filter,
        bool includeTotalCount = true,
      }) async {
        

        final f = <String, dynamic>{
          "userId": widget.user.id,
          "isApproved": true,
          "page": page,
          "pageSize": pageSize,
          "includeTotalCount": includeTotalCount,
          if (filter != null && filter.trim().isNotEmpty) "FTS": filter.trim(),
        };

        final SearchResult<Reservation> res = await _reservationProvider.get(
          filter: f,
        );

        return res;
      },
    );

    _loadPageWithExtras();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _reservationPaging.dispose(); 
    super.dispose();
  }

  Future<void> _loadPageWithExtras({int? pageNumber, String? filter}) async {
    await _reservationPaging.loadPage(pageNumber: pageNumber, filter: filter);
    if (!mounted) return;
    await _loadAuxForCurrentPage();
  }

  Future<void> _nextPageWithExtras() async {
    if (!_reservationPaging.hasNextPage) return;
    await _reservationPaging.nextPage();
    if (!mounted) return;
    await _loadAuxForCurrentPage();
  }

  Future<void> _prevPageWithExtras() async {
    if (!_reservationPaging.hasPreviousPage) return;
    await _reservationPaging.previousPage();
    if (!mounted) return;
    await _loadAuxForCurrentPage();
  }

  Future<void> _searchWithExtras(String value) async {
    _searchText = value;
    await _reservationPaging.search(value);
    if (!mounted) return;
    await _loadAuxForCurrentPage();

  }

  Future<void> _loadAuxForCurrentPage() async {
    final reservations = _reservationPaging.items;

    final Map<int, Property> loadedProperties = {};
    for (final r in reservations) {
      if (!loadedProperties.containsKey(r.propertyId)) {
        final p = await _propertyProvider.getById(r.propertyId);
        loadedProperties[r.propertyId] = p;
      }
    }

    final paymentResult = await _paymentProvider.get(
      filter: {"userId": widget.user.id},
    );
    final payments = paymentResult.items;

    final Map<int, Payment?> shortStayMap = {};
    for (final r in reservations) {
      if (r.isMonthly == false) {
        final pid = r.propertyId;
        final list = payments.where((p) => p.propertyId == pid).toList();
        list.sort((a, b) => (b.id).compareTo(a.id)); 
        shortStayMap[pid] = list.isNotEmpty ? list.first : null;
      }
    }

    setState(() {
      _propertiesMap = loadedProperties;
      _shortStayPaymentByPropertyId = shortStayMap;
    });
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

Widget _rentifyActionButton({
  required BuildContext context,
  required bool enabled,
  required Reservation r,
  required Property? property,
  required bool hasShortStayPayment,
  required Payment? shortStayPayment,
}) {
  ButtonStyle style = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF5F9F3B),
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  if (r.isMonthly == true) {
    return ElevatedButton.icon(
      onPressed: !enabled
          ? null
          : () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PaymentListScreen(
                    user: widget.user,
                    property: property!,
                  ),
                ),
              );
              await _loadPageWithExtras(filter: _searchText);
            },
      style: style,
      icon: const Icon(Icons.payments_rounded, size: 18),
      label: const Text(
        "Lista plaćanja",
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  // short stay
  if (hasShortStayPayment) {
    return ElevatedButton.icon(
      onPressed: !enabled
          ? null
          : () async {
              final refreshed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentEditingScreen(
                    user: widget.user,
                    property: property!,
                    payment: shortStayPayment!,
                    isMonthly: false,
                  ),
                ),
              );

              if (refreshed == true && mounted) {
                await _loadPageWithExtras(filter: _searchText);
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
    onPressed: !enabled
        ? null
        : () async {
            final refreshed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentAddingScreen(
                  user: widget.user,
                  property: property!,
                  billMonth: DateTime.now().month,
                  billYear: DateTime.now().year,
                  isMonthly: false,
                  reservation: r,
                ),
              ),
            );

            if (refreshed == true && mounted) {
              await _loadPageWithExtras(filter: _searchText);
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

  Widget _statusChip(Payment? p) {
    final isPayed = p?.isPayed == true;
    final bg = isPayed ? Colors.green : Colors.orange;
    final text = isPayed ? "Uplaćeno" : "Na čekanju";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        "Status: $text",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _pagingControls() {
    final paging = _reservationPaging;
    final totalPages = ((paging.totalCount + paging.pageSize - 1) ~/ paging.pageSize);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: paging.hasPreviousPage ? _prevPageWithExtras : null,
          icon: const Icon(Icons.arrow_back),
        ),
        Text("${paging.page + 1} / ${totalPages == 0 ? 1 : totalPages}"),
        IconButton(
          onPressed: paging.hasNextPage ? _nextPageWithExtras : null,
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final paging = _reservationPaging;
    final reservations = paging.items;

    return RentifyBasePage(
      title: "Stanje uplata: ${widget.user.firstName} ${widget.user.lastName}",
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) async {
                  await _searchWithExtras(v);
                },
                decoration: InputDecoration(
                  hintText: "Pretraga (npr. naziv nekretnine, vrste rezervacije)",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () async {
                            _searchCtrl.clear();
                            await _searchWithExtras("");
                          },
                        ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // BODY
            Expanded(
              child: paging.isLoading && reservations.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : reservations.isEmpty
                      ? const Center(child: Text("Nema rezervacija za ovog korisnika."))
                      : ListView.builder(
                          itemCount: reservations.length,
                          itemBuilder: (context, index) {
                            final r = reservations[index];
                            final property = _propertiesMap[r.propertyId];
                            final propertyName = property?.name ?? "Učitavanje...";

                            final shortStayPayment = _shortStayPaymentByPropertyId[r.propertyId];
                            final hasShortStayPayment = shortStayPayment != null;

                            return Container(
  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER ROW
        Row(
          children: [
            // Title
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
                      propertyName.isEmpty ? "Nekretnina" : propertyName,
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

            // Status chip (samo za short-stay)
            if (r.isMonthly == false && shortStayPayment != null) ...[
              const SizedBox(width: 10),
              _statusChip(shortStayPayment),
            ],
          ],
        ),

        const SizedBox(height: 12),

        _infoRow(
          icon: Icons.category_rounded,
          label: "Vrsta rezervacije",
          value: r.isMonthly == true ? "Najamnina" : "Kratki boravak",
        ),

        if (r.startDateOfRenting != null)
          _infoRow(
            icon: Icons.event_available_rounded,
            label: "Datum početka",
            value: DateHelper.formatNullable(r.startDateOfRenting),
          ),

        if (r.endDateOfRenting != null)
          _infoRow(
            icon: Icons.event_busy_rounded,
            label: "Datum kraja",
            value: DateHelper.formatNullable(r.endDateOfRenting),
          ),

        const SizedBox(height: 14),

        // ACTION BUTTON (right aligned)
        Align(
          alignment: Alignment.centerRight,
          child: _rentifyActionButton(
            context: context,
            enabled: property != null,
            r: r,
            property: property,
            hasShortStayPayment: hasShortStayPayment,
            shortStayPayment: shortStayPayment,
          ),
        ),
      ],
    ),
  ),
);
                          },
                        ),
            ),

            // PAGING CONTROLS
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _pagingControls(),
            ),
          ],
        ),
      ),
    );
  }
}

