import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rentify_desktop/dialogs/base_dialogs.dart';
import 'package:rentify_desktop/dialogs/confirmation_dialogs.dart';
import 'package:rentify_desktop/helper/exception_read_helper.dart';
import 'package:rentify_desktop/helper/snackBar_helper.dart';
import 'package:rentify_desktop/models/appointment.dart';
import 'package:rentify_desktop/providers/appointment_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/screens/base_search_list_screen.dart';
import 'package:rentify_desktop/utils/session.dart';

String fmtDateTime(DateTime? d) {
  if (d == null) return "-";
  final local = d.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return "${two(local.day)}.${two(local.month)}.${local.year} ${two(local.hour)}:${two(local.minute)}";
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
  int? _selectedStatusId;

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

      final result = await provider.get(
        filter: {
          "FTS": _fts.isNotEmpty ? _fts : null,
          "page": _page,
          "pageSize": _pageSize,
          "includeTotalCount": true,
          "includeUser": true,
          "includeProperty": true,
          "ownerId": Session.userId,
          "statusId": _selectedStatusId,
        }..removeWhere((k, v) => v == null),
      );

      if (!mounted) return;

      setState(() {
        _items = result.items;
        _totalCount = result.totalCount ?? result.items.length;
      });
    } catch (e) {
      SnackbarHelper.showError(context, extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _maxPage => _totalCount == 0 ? 0 : ((_totalCount - 1) ~/ _pageSize);

  String _statusName(Appointment a) =>
      (a.status?.name ?? _statusLabel(a.statusId)).trim();

  String _statusLabel(int statusId) {
    switch (statusId) {
      case 1:
        return "Na cekanju";
      case 2:
        return "Odobreno";
      case 3:
        return "Zavrseno";
      case 4:
        return "Odbijeno";
      case 5:
        return "Otkazano";
      default:
        return "-";
    }
  }

  List<String> _getAllowedStatusesForUi(String? currentStatus) {
    final s = (currentStatus ?? "").trim();

    switch (s) {
      case "Na čekanju":
        return [
          "Na čekanju",
          "Odobreno",
          "Odbijeno",
          "Otkazano",
          "Završeno",
        ];
      case "Odobreno":
        return [
          "Odobreno",
          "Otkazano",
          "Završeno",
        ];
      case "Odbijeno":
        return ["Odbijeno"];
      case "Otkazano":
        return ["Otkazano"];
      case "Završeno":
        return ["Završeno"];
      default:
        return ["Na čekanju"];
    }
  }

  bool _isLockedStatus(String? status) {
    final s = (status ?? "").trim();
    return s == "Odbijeno" || s == "Otkazano" || s == "Završeno";
  }

  Future<bool> _executeStatusChange(
    AppoitmentProvider provider,
    Appointment appointment,
    String oldStatus,
    String newStatus,
  ) async {
    final id = appointment.id;
    if (id == null) {
      throw Exception("Termin nema validan ID.");
    }

    if (newStatus == oldStatus) return true;

    switch (newStatus) {
      case "Odobreno":
        await provider.approve(id);
        break;
      case "Odbijeno":
        final reason = await ConfirmDialogs.reasonPrompt(
          context,
          title: "Razlog odbijanja",
          message: "Unesite razlog odbijanja termina:",
        );
        if (reason == null) return false;
        await provider.reject(id, reason);
        break;
      case "Otkazano":
        final reason = await ConfirmDialogs.reasonPrompt(
          context,
          title: "Razlog otkazivanja",
          message: "Unesite razlog otkazivanja termina:",
        );
        if (reason == null) return false;
        await provider.cancel(id, reason);
        break;
      case "Završeno":
        await provider.finish(id);
        break;
      default:
        throw Exception("Nedozvoljena promjena statusa.");
    }

    return true;
  }

  String _statusActionSuccessMessage(String newStatus) {
    switch (newStatus) {
      case "Odobreno":
        return "Termin je uspješno odobren.";
      case "Odbijeno":
        return "Termin je uspješno odbijen.";
      case "Otkazano":
        return "Termin je uspješno otkazan.";
      case "Završeno":
        return "Termin je uspješno završen.";
      default:
        return "Status termina je uspješno promijenjen.";
    }
  }

  Future<void> _changeStatus(Appointment a) async {
    final provider = context.read<AppoitmentProvider>();

    final currentStatus = (_statusName(a).isNotEmpty == true)
        ? _statusName(a)
        : "Na čekanju";

    String selectedStatus = currentStatus;

    final allowedStatuses = _getAllowedStatusesForUi(currentStatus);
    final isLocked = _isLockedStatus(currentStatus);

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            final hasChanged = selectedStatus != currentStatus;

            return RentifyBaseDialog(
              title: "Promjena statusa termina",
              width: 560,
              onClose: () => Navigator.of(dialogContext).pop(false),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DialogInfoRow(
                    label: "Korisnik",
                    value:
                        "${a.user?.firstName ?? ""} ${a.user?.lastName ?? ""}"
                                .trim()
                                .isEmpty
                            ? "Korisnik #${a.userId}"
                            : "${a.user?.firstName ?? ""} ${a.user?.lastName ?? ""}"
                                .trim(),
                  ),
                  const SizedBox(height: 10),
                  _DialogInfoRow(
                    label: "Nekretnina",
                    value: a.property?.name ?? "PropertyId: ${a.propertyId}",
                  ),
                  const SizedBox(height: 10),
                  _DialogInfoRow(
                    label: "Termin",
                    value: fmtDateTime(a.dateAppointment),
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
                    value: allowedStatuses.contains(selectedStatus)
                        ? selectedStatus
                        : allowedStatuses.first,
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
                    items: allowedStatuses
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
                    onChanged: isLocked
                        ? null
                        : (value) {
                            if (value == null) return;
                            setInnerState(() {
                              selectedStatus = value;
                            });
                          },
                  ),
                  if (isLocked) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "Ovaj status je zaključan i više se ne može mijenjati.",
                      style: TextStyle(
                        color: Color(0xFFC62828),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
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
                          onPressed: (!hasChanged || isLocked)
                              ? null
                              : () => Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5F9F3B),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFBDBDBD),
                            disabledForegroundColor: Colors.white70,
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
      final proceeded = await _executeStatusChange(provider, a, currentStatus, selectedStatus);
      if (!proceeded || !mounted) return;

      setState(() {
        _selectedStatusId = null;
        _page = 0;
      });

      await _load(page: 0);
      SnackbarHelper.showSuccess(context, _statusActionSuccessMessage(selectedStatus));
    } catch (e) {
      SnackbarHelper.showError(context, extractErrorMessage(e));
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
      SnackbarHelper.showSuccess(context, "Termin je uspjesno obrisan");
    } catch (e) {
      SnackbarHelper.showError(context, extractErrorMessage(e));
    }
  }

  Future<void> _setStatusFilter(int? statusId) async {
    setState(() {
      _selectedStatusId = statusId;
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
          selected: _selectedStatusId == null,
          onTap: () => _setStatusFilter(null),
          color: const Color(0xFF5F9F3B),
        ),
        _StatusChip(
          label: "Odobreni",
          selected: _selectedStatusId == 2,
          onTap: () => _setStatusFilter(2),
          color: Colors.green,
        ),
        _StatusChip(
          label: "Na čekanju",
          selected: _selectedStatusId == 1,
          onTap: () => _setStatusFilter(1),
          color: const Color(0xFF5F9F3B),
        ),
        _StatusChip(
          label: "Završeni",
          selected: _selectedStatusId == 3,
          onTap: () => _setStatusFilter(3),
          color: Colors.blue,
        ),
        _StatusChip(
          label: "Odbijeni",
          selected: _selectedStatusId == 4,
          onTap: () => _setStatusFilter(4),
          color: const Color(0xFF6B7280),
        ),
        _StatusChip(
          label: "Otkazani",
          selected: _selectedStatusId == 5,
          onTap: () => _setStatusFilter(5),
          color: Colors.red,
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
      case "Odbijeno":
        return const Color(0xFF6B7280);
      case "Otkazano":
        return Colors.red;
      default:
        return Colors.grey;
    }
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
                cell: (x) => Text(
                  "${x.user?.firstName ?? ""} ${x.user?.lastName ?? ""}".trim(),
                ),
              ),
              BaseColumn<Appointment>(
                title: "Nekretnina",
                flex: 2,
                cell: (x) =>
                    Text(x.property?.name ?? "PropertyId: ${x.propertyId}"),
              ),
              BaseColumn<Appointment>(
                title: "Datum termina",
                flex: 2,
                cell: (x) => Text(fmtDateTime(x.dateAppointment)),
              ),
              BaseColumn<Appointment>(
                title: "Status",
                flex: 1,
                cell: (x) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(_statusName(x)).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: _statusColor(_statusName(x)).withOpacity(0.28),
                    ),
                  ),
                  child: Text(
                    _statusName(x),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _statusColor(_statusName(x)),
                    ),
                  ),
                ),
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

  const _DialogInfoRow({required this.label, required this.value});

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
          child: Text(value, style: const TextStyle(color: Color(0xFF4A4A4A))),
        ),
      ],
    );
  }
}
