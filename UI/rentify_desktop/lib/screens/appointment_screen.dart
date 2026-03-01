import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rentify_desktop/dialogs/confirmation_dialogs.dart';
import 'package:rentify_desktop/models/appointment.dart';
import 'package:rentify_desktop/providers/appointment_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/screens/base_search_list_screen.dart';
import 'package:rentify_desktop/utils/session.dart';

String fmtDateTime(DateTime? d) {
  if (d == null) return "-";
  String two(int n) => n.toString().padLeft(2, '0');
  return "${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}";
}

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  static const int _pageSize = 8;

  int _page = 0;
  int _totalCount = 0;
  bool _loading = false;

  String _fts = "";
  List<Appointment> _items = [];

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
      final provider = context.read<AppoitmentProvider>();

      final result = await provider.get(filter: {
        "FTS": _fts.isNotEmpty ? _fts : null,
        "page": _page,
        "pageSize": _pageSize,
        "includeTotalCount": true,
        "includeUser": true,
        "includeProperty": true,
        "ownerId": Session.userId, 
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

  int get _maxPage => _totalCount == 0 ? 0 : ((_totalCount - 1) ~/ _pageSize);

  Map<String, dynamic> appointmentPutPayload(
    Appointment a, {
    required bool? isApproved,
  }) {
    String? dt(DateTime? d) => d?.toIso8601String();

    return {
      "id": a.id,
      "userId": a.userId,
      "propertyId": a.propertyId,
      "dateAppointment": dt(a.dateAppointment),
      "isApproved": isApproved,
    };
  }

  Future<void> _changeStatus(Appointment a) async {
    final provider = context.read<AppoitmentProvider>();

    final question =
        "Termin #${a.id}\n"
        "Korisnik: ${a.user == null ? a.userId : "${a.user!.firstName} ${a.user!.lastName}"}\n"
        "Nekretnina: ${a.property?.name ?? a.propertyId}\n"
        "Datum: ${fmtDateTime(a.dateAppointment)}\n\n"
        "Odaberi akciju:";

    final res = await ConfirmDialogs.badGoodConfirmation(
      context,
      title: "Promjena statusa termina",
      question: question,
      goodText: "Odobri",
      badText: "Odbij",
      barrierDismissible: true,
    );

    if (res == TriConfirmResult.cancel) return;

    final approved = (res == TriConfirmResult.good);

    try {
      final payload = appointmentPutPayload(a, isApproved: approved);
      await provider.update(a.id, payload);
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

  Future<void> _deleteAppointment(Appointment a) async {
    final ok = await ConfirmDialogs.yesNoConfirmation(
      context,
      title: "Brisanje termina",
      question:
          "Da li sigurno želiš obrisati termin #${a.id}?\n\n"
          "Ova radnja je trajna i ne može se poništiti.",
      yesText: "Obriši",
      noText: "Odustani",
    );

    if (!ok) return;

    try {
      await context.read<AppoitmentProvider>().delete(a.id);
      await _load();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Termin uspješno obrisan.")),
      );
    } catch (e) {
      if (!mounted) return;

      await ConfirmDialogs.okConfirmation(
        context,
        title: "Greška",
        message: "Ne mogu obrisati termin:\n$e",
      );
    }
  }

  Widget _footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Ukupno: $_totalCount",
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        Row(
          children: [
            IconButton(
              onPressed: (_page <= 0 || _loading)
                  ? null
                  : () => _load(page: _page - 1),
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              "${_page + 1} / ${_maxPage + 1}",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            IconButton(
              onPressed: (_page >= _maxPage || _loading)
                  ? null
                  : () => _load(page: _page + 1),
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
      title: "Termini",
      child: Stack(
        children: [
          BaseSearchAndTable<Appointment>(
            title: "Termini",
            addButtonText: null,
            items: _items,
            onSearchChanged: (v) async => _load(page: 0, fts: v),
            onClearSearch: () => _load(page: 0, fts: ""),
            isStatusMode: true,
            editLabel: "Status",
            columns: [
              BaseColumn<Appointment>(
                title: "Korisnik",
                flex: 2,
                cell: (x) => Text("${x.user?.firstName ?? ""} ${x.user?.lastName ?? ""}".trim()),
              ),
              BaseColumn<Appointment>(
                title: "Nekretnina",
                flex: 2,
                cell: (x) => Text(x.property?.name ?? "PropertyId: ${x.propertyId}"),
              ),
              BaseColumn<Appointment>(
                title: "Datum termina",
                flex: 2,
                cell: (x) => Text(fmtDateTime(x.dateAppointment)),
              ),
              BaseColumn<Appointment>(
                title: "Status",
                flex: 1,
                cell: (x) {
                  final s = x.isApproved;
                  final label = s == null ? "Na čekanju" : (s ? "Odobreno" : "Odbijeno");
                  return Text(label, style: const TextStyle(fontWeight: FontWeight.w700));
                },
              ),
            ],
            onEdit: _changeStatus,
            onDelete: _deleteAppointment,
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