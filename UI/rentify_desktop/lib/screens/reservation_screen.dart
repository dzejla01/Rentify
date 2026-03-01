import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/dialogs/confirmation_dialogs.dart';
import 'package:rentify_desktop/models/reservation.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/providers/reservation_provider.dart';
import 'package:rentify_desktop/screens/base_search_list_screen.dart';
import 'package:rentify_desktop/utils/session.dart';

String fmtDate(DateTime? d) {
  if (d == null) return "-";
  String two(int n) => n.toString().padLeft(2, '0');
  return "${two(d.day)}.${two(d.month)}.${d.year}";
}

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  static const int _pageSize = 8;

  int _page = 0;
  int _totalCount = 0;
  bool _loading = false;

  String _fts = "";
  List<Reservation> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load({int? page, String? fts}) async {
    if (_loading) return;

    setState(() {
      _loading = true;
      if (page != null) _page = page;
      if (fts != null) _fts = fts;
    });

    try {
      final provider = context.read<ReservationProvider>();

      final result = await provider.get(filter: {
        "FTS": _fts.isNotEmpty ? _fts : null,
        "page": _page,
        "pageSize": _pageSize,
        "includeTotalCount": true,
        "includeUser": true,
        "includeProperty": true,
        "ownerId": Session.userId
      }..removeWhere((k, v) => v == null));

      setState(() {
        _items = result.items;
        _totalCount = result.totalCount ?? result.items.length;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _maxPage =>
      _totalCount == 0 ? 0 : ((_totalCount - 1) ~/ _pageSize);


  Map<String, dynamic> reservationPutPayload(Reservation r, {required bool? isApproved}) {
  String? dt(DateTime? d) => d?.toIso8601String();

  return {
    "id": r.id,
    "userId": r.userId,
    "propertyId": r.propertyId,
    "isMonthly": r.isMonthly,
    "isApproved": isApproved,
    "createdAt": dt(r.createdAt),
    "startDateOfRenting": dt(r.startDateOfRenting),
    "endDateOfRenting": dt(r.endDateOfRenting),
  };
}

  Future<void> _changeStatus(Reservation r) async {
  final provider = context.read<ReservationProvider>();

  final question =
      "Rezervacija #${r.id}\n"
      "Korisnik: ${r.user == null ? r.userId : "${r.user!.firstName} ${r.user!.lastName}"}\n"
      "Nekretnina: ${r.property?.name ?? r.propertyId}\n\n"
      "Odaberi akciju:";

  final res = await ConfirmDialogs.badGoodConfirmation(
    context,
    title: "Promjena statusa",
    question: question,
    goodText: "Odobri",
    badText: "Odbij",
    barrierDismissible: true,
  );

  if (res == TriConfirmResult.cancel) return;

  final approved = (res == TriConfirmResult.good);

  try {
    final payload = reservationPutPayload(r, isApproved: approved);
    await provider.update(r.id, payload);
    await _load();
  } catch (e) {
    if (!mounted) return;
    await ConfirmDialogs.okConfirmation(
      context,
      title: "Greška",
      message: "Ne mogu promijeniti status: $e",
    );
  }
}

  Future<void> _deleteReservation(Reservation r) async {
  final ok = await ConfirmDialogs.yesNoConfirmation(
    context,
    title: "Brisanje rezervacije",
    question:
        "Da li sigurno želiš obrisati rezervaciju #${r.id}?\n\n"
        "Ova radnja je trajna i ne može se poništiti.",
    yesText: "Obriši",
    noText: "Odustani",
  );

  if (!ok) return;

  try {
    await context.read<ReservationProvider>().delete(r.id);
    await _load();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Rezervacija uspješno obrisana."),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    await ConfirmDialogs.okConfirmation(
      context,
      title: "Greška",
      message: "Ne mogu obrisati rezervaciju:\n$e",
    );
  }
}

  Widget _footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Ukupno: $_totalCount", style: const TextStyle(fontWeight: FontWeight.w700)),
        Row(
          children: [
            IconButton(
              onPressed: (_page <= 0 || _loading) ? null : () => _load(page: _page - 1),
              icon: const Icon(Icons.chevron_left),
            ),
            Text("${_page + 1} / ${_maxPage + 1}", style: const TextStyle(fontWeight: FontWeight.w700)),
            IconButton(
              onPressed: (_page >= _maxPage || _loading) ? null : () => _load(page: _page + 1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: "Rezervacije",
      child: Stack(
        children: [
          BaseSearchAndTable<Reservation>(
            title: "Rezervacije",
            addButtonText: null, 
            items: _items,
            onSearchChanged: (v) async => _load(page: 0, fts: v),
            onClearSearch: () => _load(page: 0, fts: ""),
            isStatusMode: true,
            editLabel: "Status",
            columns: [
              BaseColumn<Reservation>(
                title: "Korisnik",
                flex: 2,
                cell: (x) => Text("${x.user?.firstName} ${x.user?.lastName}"),
              ),
              BaseColumn<Reservation>(
                title: "Nekretnina",
                flex: 2,
                cell: (x) => Text(x.property?.name ?? "PropertyId: ${x.propertyId}"),
              ),
              BaseColumn<Reservation>(
                title: "Period",
                flex: 2,
                cell: (x) => Text("${fmtDate(x.startDateOfRenting)} - ${fmtDate(x.endDateOfRenting)}"),
              ),
              BaseColumn<Reservation>(
                title: "Tip",
                flex: 1,
                cell: (x) => Text(x.isMonthly ? "Najamnina" : "Kratki boravak"),
              ),
              BaseColumn<Reservation>(
                title: "Status",
                flex: 1,
                cell: (x) {
                  final s = x.isApproved;
                  final label = s == null ? "Na čekanju" : (s ? "Odobreno" : "Odbijeno");
                  return Text(label, style: const TextStyle(fontWeight: FontWeight.w700));
                },
              ),
              BaseColumn<Reservation>(
                title: "Kreirano",
                flex: 1,
                cell: (x) => Text(fmtDate(x.createdAt)),
              ),
            ],
            onEdit: _changeStatus,
            onDelete: _deleteReservation,
            footer: _footer(),
          ),
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.55),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}