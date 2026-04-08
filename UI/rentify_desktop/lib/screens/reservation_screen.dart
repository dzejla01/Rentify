import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/dialogs/base_dialogs.dart';
import 'package:rentify_desktop/dialogs/confirmation_dialogs.dart';
import 'package:rentify_desktop/models/reservation.dart';
import 'package:rentify_desktop/providers/reservation_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
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

  static const List<String> _statusOptions = [
    "Na čekanju",
    "Odobreno",
    "Završeno",
  ];

  int _page = 0;
  int _totalCount = 0;
  bool _loading = false;

  String _fts = "";
  String? _selectedStatusFilter;

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

      final result = await provider.get(
        filter: {
          "FTS": _fts.isNotEmpty ? _fts : null,
          "page": _page,
          "pageSize": _pageSize,
          "ownerId": Session.userId,
          "includeTotalCount": true,
          "includeUser": true,
          "includeProperty": true,
          "status": _selectedStatusFilter,
        }..removeWhere((k, v) => v == null),
      );

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

  Map<String, dynamic> reservationPutPayload(
  Reservation r, {
  required String status,
}) {
  String? dt(DateTime? d) => d?.toIso8601String();

  return {
    "userId": r.userId,
    "propertyId": r.propertyId,
    "isMonthly": r.isMonthly,
    "status": status,
    "createdAt": dt(r.createdAt),
    "startDateOfRenting": dt(r.startDateOfRenting),
    "endDateOfRenting": dt(r.endDateOfRenting),
  };
}

  Future<void> _changeStatus(Reservation r) async {
  final provider = context.read<ReservationProvider>();

  String selectedStatus = (r.status?.trim().isNotEmpty == true)
      ? r.status!.trim()
      : "Na čekanju";

  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setInnerState) {
          return RentifyBaseDialog(
            title: "Promjena statusa rezervacije",
            width: 560,
            onClose: () => Navigator.of(dialogContext).pop(false),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogInfoRow(
                  label: "Korisnik",
                  value:
                      "${r.user?.firstName ?? ""} ${r.user?.lastName ?? ""}"
                          .trim()
                          .isEmpty
                      ? "Korisnik #${r.userId}"
                      : "${r.user?.firstName ?? ""} ${r.user?.lastName ?? ""}"
                            .trim(),
                ),
                const SizedBox(height: 10),
                _DialogInfoRow(
                  label: "Nekretnina",
                  value: r.property?.name ?? "PropertyId: ${r.propertyId}",
                ),
                const SizedBox(height: 10),
                _DialogInfoRow(
                  label: "Period",
                  value:
                      "${fmtDate(r.startDateOfRenting)} - ${fmtDate(r.endDateOfRenting)}",
                ),
                const SizedBox(height: 10),
                _DialogInfoRow(
                  label: "Tip",
                  value: r.isMonthly ? "Najamnina" : "Kratki boravak",
                ),
                const SizedBox(height: 18),
                const Text(
                  "Odaberite novi status",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _statusOptions.contains(selectedStatus)
                      ? selectedStatus
                      : "Na čekanju",
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.10),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.10),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF5F9F3B),
                        width: 2,
                      ),
                    ),
                  ),
                  items: _statusOptions
                      .map(
                        (status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setInnerState(() {
                      selectedStatus = value;
                    });
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6E6E6E),
                          side: const BorderSide(color: Color(0xFFBDBDBD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Odustani",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5F9F3B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Sačuvaj",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );

  if (saved != true) return;

  try {
    final payload = reservationPutPayload(r, status: selectedStatus);
    await provider.update(r.id, payload);

    if (!mounted) return;

    setState(() {
      _selectedStatusFilter = selectedStatus;
      _page = 0;
    });

    await _load(page: 0);
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
          "Da li ste sigurni da želite obrisati rezervaciju #${r.id}?\n\n"
          "Nakon brisanja podaci se NE mogu vratiti.",
      yesText: "Trajno obriši",
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

  Future<void> _setStatusFilter(String? status) async {
    setState(() {
      _selectedStatusFilter = status;
      _page = 0;
    });

    await _load(page: 0);
  }

  Widget _buildStatusFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatusChip(
          label: "Sve",
          selected: _selectedStatusFilter == null,
          onTap: () => _setStatusFilter(null),
          color: const Color(0xFF5F9F3B),
        ),
        _StatusChip(
          label: "Odobrene",
          selected: _selectedStatusFilter == "Odobreno",
          onTap: () => _setStatusFilter("Odobreno"),
          color: Colors.green,
        ),
        _StatusChip(
          label: "Na čekanju",
          selected: _selectedStatusFilter == "Na čekanju",
          onTap: () => _setStatusFilter("Na čekanju"),
          color: const Color(0xFF5F9F3B),
        ),
        _StatusChip(
          label: "Završene",
          selected: _selectedStatusFilter == "Završeno",
          onTap: () => _setStatusFilter("Završeno"),
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _footer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusFilters(),
        const SizedBox(height: 12),
        Row(
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
        ),
      ],
    );
  }

  Color _statusColor(String? status) {
    switch ((status ?? "").trim()) {
      case "Odobreno":
        return Colors.green;
      case "Na čekanju":
        return const Color(0xFF5F9F3B);
      case "Završeno":
        return Colors.blue;
      default:
        return Colors.grey;
    }
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
                cell: (x) => Text(
                  "${x.user?.firstName ?? ""} ${x.user?.lastName ?? ""}".trim(),
                ),
              ),
              BaseColumn<Reservation>(
                title: "Nekretnina",
                flex: 2,
                cell: (x) => Text(
                  x.property?.name ?? "PropertyId: ${x.propertyId}",
                ),
              ),
              BaseColumn<Reservation>(
                title: "Period",
                flex: 2,
                cell: (x) => Text(
                  "${fmtDate(x.startDateOfRenting)} - ${fmtDate(x.endDateOfRenting)}",
                ),
              ),
              BaseColumn<Reservation>(
                title: "Tip",
                flex: 1,
                cell: (x) => Text(
                  x.isMonthly ? "Najamnina" : "Kratki boravak",
                ),
              ),
              BaseColumn<Reservation>(
                title: "Status",
                flex: 1,
                cell: (x) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(x.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: _statusColor(x.status).withOpacity(0.28),
                    ),
                  ),
                  child: Text(
                    x.status ?? "-",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _statusColor(x.status),
                    ),
                  ),
                ),
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
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : Colors.black.withOpacity(0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF374151),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DialogInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _DialogInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child: Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF4A4A4A),
            ),
          ),
        ),
      ],
    );
  }
}