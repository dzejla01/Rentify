// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rentify_desktop/helper/date_helper.dart';
// import 'package:rentify_desktop/models/payment.dart';
// import 'package:rentify_desktop/models/property.dart';
// import 'package:rentify_desktop/models/reservation.dart';
// import 'package:rentify_desktop/models/user.dart';
// import 'package:rentify_desktop/providers/payment_provider.dart';
// import 'package:rentify_desktop/providers/property_provider.dart';
// import 'package:rentify_desktop/providers/reservation_provider.dart';
// import 'package:rentify_desktop/screens/adding_payment_screen.dart';
// import 'package:rentify_desktop/screens/base_screen.dart';
// import 'package:rentify_desktop/screens/editing_payment_screen.dart';
// import 'package:rentify_desktop/screens/payment_list_screen.dart';

// class PaymentUserScreen extends StatefulWidget {
//   final User user;

//   const PaymentUserScreen({super.key, required this.user});

//   @override
//   State<PaymentUserScreen> createState() => _PaymentUserScreenState();
// }

// class _PaymentUserScreenState extends State<PaymentUserScreen> {
//   late PropertyProvider _propertyProvider;
//   late ReservationProvider _reservationProvider;
//   late PaymentProvider _paymentProvider;

//   List<Reservation> _reservations = [];
//   Map<int, Property> _propertiesMap = {};

//   Map<int, Payment?> _shortStayPaymentByPropertyId = {};

//   bool _isLoadingReservations = true;

//   @override
//   void initState() {
//     super.initState();

//     _reservationProvider = Provider.of<ReservationProvider>(
//       context,
//       listen: false,
//     );
//     _propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
//     _paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

//     _loadReservations();
//   }

//   Future<void> _loadReservations() async {
//     setState(() {
//       _isLoadingReservations = true;
//     });

//     try {
//       final reservationsResult = await _reservationProvider.get(
//         filter: {"userId": widget.user.id, "isApproved": true},
//       );

//       final reservations = reservationsResult.items;

//       final Map<int, Property> loadedProperties = {};
//       for (final r in reservations) {
//         if (!loadedProperties.containsKey(r.propertyId)) {
//           final property = await _propertyProvider.getById(r.propertyId);
//           loadedProperties[r.propertyId] = property;
//         }
//       }

//       final paymentResult = await _paymentProvider.get(
//         filter: {"userId": widget.user.id},
//       );
//       final payments = paymentResult.items;

//       final Map<int, Payment?> shortStayMap = {};
//       for (final r in reservations) {
//         if (r.isMonthly == false) {
//           final pid = r.propertyId;
//           final list = payments.where((p) => p.propertyId == pid).toList();

//           list.sort((a, b) => (b.id).compareTo(a.id)); // najnoviji po id
//           shortStayMap[pid] = list.isNotEmpty ? list.first : null;
//         }
//       }

//       setState(() {
//         _reservations = reservations;
//         _propertiesMap = loadedProperties;
//         _shortStayPaymentByPropertyId = shortStayMap;
//         _isLoadingReservations = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoadingReservations = false;
//       });
//       debugPrint("Greška pri dohvat rezervacija: $e");
//     }
//   }

//   Widget _statusChip(Payment? p) {
//     final isPayed = p?.isPayed == true;
//     final bg = isPayed ? Colors.green : Colors.orange;
//     final text = isPayed ? "Uplaćeno" : "Na čekanju";

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(999),
//       ),
//       child: Text(
//         "Status: $text",
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RentifyBasePage(
//       title: "Stanje uplata: ${widget.user.firstName} ${widget.user.lastName}",
//       child: _isLoadingReservations
//           ? const Center(child: CircularProgressIndicator())
//           : _reservations.isEmpty
//           ? const Center(child: Text("Nema rezervacija za ovog korisnika."))
//           : ListView.builder(
//               itemCount: _reservations.length,
//               itemBuilder: (context, index) {
//                 final r = _reservations[index];
//                 final property = _propertiesMap[r.propertyId];
//                 final propertyName = property?.name ?? "Učitavanje...";

//                 final shortStayPayment =
//                     _shortStayPaymentByPropertyId[r.propertyId];
//                 final hasShortStayPayment = shortStayPayment != null;

//                 return Card(
//                   margin: const EdgeInsets.symmetric(
//                     vertical: 8,
//                     horizontal: 16,
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 "Nekretnina: $propertyName",
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             if (r.isMonthly == false &&
//                                 shortStayPayment != null)
//                               _statusChip(shortStayPayment),
//                           ],
//                         ),
//                         const SizedBox(height: 8),

//                         Text(
//                           "Vrsta rezervacije: ${r.isMonthly == true ? "Najamnina" : "Kratki boravak"}",
//                         ),

//                         if (r.startDateOfRenting != null)
//                           Text(
//                             "Datum početka: ${DateHelper.formatNullable(r.startDateOfRenting)}",
//                           ),

//                         if (r.endDateOfRenting != null)
//                           Text(
//                             "Datum kraja: ${DateHelper.formatNullable(r.endDateOfRenting)}",
//                           ),

//                         const SizedBox(height: 12),

//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: r.isMonthly == true
//                               ? ElevatedButton(
//                                   onPressed: property == null
//                                       ? null
//                                       : () async {
//                                           await Navigator.of(context).push(
//                                             MaterialPageRoute(
//                                               builder: (_) => PaymentListScreen(
//                                                 user: widget.user,
//                                                 property: property,
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                   child: const Text("Otvori listu plaćanja"),
//                                 )
//                               : (hasShortStayPayment
//                                     ? ElevatedButton(
//                                         onPressed: property == null
//                                             ? null
//                                             : () async {
//                                                 final refreshed =
//                                                     await Navigator.push<bool>(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (_) =>
//                                                             PaymentEditingScreen(
//                                                               user: widget.user,
//                                                               property:
//                                                                   property,
//                                                               payment:
//                                                                   shortStayPayment!,
//                                                               isMonthly: false,
//                                                             ),
//                                                       ),
//                                                     );

//                                                 if (refreshed == true &&
//                                                     mounted) {
//                                                   await _loadReservations();
//                                                 }
//                                               },
//                                         child: const Text("Pregled zahtjeva"),
//                                       )
//                                     : ElevatedButton(
//                                         onPressed: property == null
//                                             ? null
//                                             : () async {
//                                                 final refreshed =
//                                                     await Navigator.push<bool>(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (_) =>
//                                                             PaymentAddingScreen(
//                                                               user: widget.user,
//                                                               property:
//                                                                   property,
//                                                               billMonth:
//                                                                   DateTime.now()
//                                                                       .month,
//                                                               billYear:
//                                                                   DateTime.now()
//                                                                       .year,
//                                                               isMonthly: false,
//                                                               reservation: r,
//                                                             ),
//                                                       ),
//                                                     );

//                                                 if (refreshed == true &&
//                                                     mounted) {
//                                                   await _loadReservations();
//                                                 }
//                                               },
//                                         child: const Text("Pošalji zahtjev"),
//                                       )),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

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

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Nekretnina: $propertyName",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (r.isMonthly == false && shortStayPayment != null)
                                          _statusChip(shortStayPayment),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    Text(
                                      "Vrsta rezervacije: ${r.isMonthly == true ? "Najamnina" : "Kratki boravak"}",
                                    ),

                                    if (r.startDateOfRenting != null)
                                      Text(
                                        "Datum početka: ${DateHelper.formatNullable(r.startDateOfRenting)}",
                                      ),

                                    if (r.endDateOfRenting != null)
                                      Text(
                                        "Datum kraja: ${DateHelper.formatNullable(r.endDateOfRenting)}",
                                      ),

                                    const SizedBox(height: 12),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: r.isMonthly == true
                                          ? ElevatedButton(
                                              onPressed: property == null
                                                  ? null
                                                  : () async {
                                                      await Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                          builder: (_) => PaymentListScreen(
                                                            user: widget.user,
                                                            property: property,
                                                          ),
                                                        ),
                                                      );
                                                      // ako želiš i ovdje refresh nakon povratka:
                                                      await _loadPageWithExtras(filter: _searchText);
                                                    },
                                              child: const Text("Otvori listu plaćanja"),
                                            )
                                          : (hasShortStayPayment
                                              ? ElevatedButton(
                                                  onPressed: property == null
                                                      ? null
                                                      : () async {
                                                          final refreshed =
                                                              await Navigator.push<bool>(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) => PaymentEditingScreen(
                                                                user: widget.user,
                                                                property: property,
                                                                payment: shortStayPayment!,
                                                                isMonthly: false,
                                                              ),
                                                            ),
                                                          );

                                                          if (refreshed == true && mounted) {
                                                            await _loadPageWithExtras(filter: _searchText);
                                                          }
                                                        },
                                                  child: const Text("Pregled zahtjeva"),
                                                )
                                              : ElevatedButton(
                                                  onPressed: property == null
                                                      ? null
                                                      : () async {
                                                          final refreshed =
                                                              await Navigator.push<bool>(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) => PaymentAddingScreen(
                                                                user: widget.user,
                                                                property: property,
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
                                                  child: const Text("Pošalji zahtjev"),
                                                )),
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

