import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/dialogs/confirmation_dialogs.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/providers/appoitment_provider.dart';
import 'package:rentify_mobile/routes/app_routes.dart';
import 'package:rentify_mobile/utils/session.dart';

class PropertyAppointmentUniversalScreen extends StatefulWidget {
  const PropertyAppointmentUniversalScreen({
    super.key,
    required this.property,
    this.unavailableAppointments = const [],
  });

  final Property property;

  final List<DateTime> unavailableAppointments;

  @override
  State<PropertyAppointmentUniversalScreen> createState() =>
      _PropertyAppointmentUniversalScreenState();
}

class _PropertyAppointmentUniversalScreenState
    extends State<PropertyAppointmentUniversalScreen> {
  static const rentifyGreenDark = Color(0xFF5F9F3B);

  DateTime _visibleMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  DateTime? _selectedDate; 
  TimeOfDay? _selectedTime;

  late final Set<DateTime> _unavailableDateTimes; 
  late final Set<DateTime> _unavailableDates;

  bool _loadingUnavailable = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    _unavailableDateTimes = widget.unavailableAppointments
        .map(_normalizeMinuteUtc)
        .toSet();

    _unavailableDates =
    widget.unavailableAppointments.map(_normalizeDateUtc).toSet();

    _loadUnavailableAppointments();
  }

  Future<void> _loadUnavailableAppointments() async {
    setState(() => _loadingUnavailable = true);

    try {
      final provider = AppoitmentProvider();

      final resp = await provider.getUnavailableDates(
        propertyId: widget.property.id,
        from: DateTime.now(),
        to: DateTime.now().add(const Duration(days: 180)),
      );

      if (!mounted) return;

      setState(() {
        _unavailableDateTimes
          ..clear()
          ..addAll(resp.dateTimes.map(_normalizeMinuteUtc)); 
          _unavailableDates
    ..clear()
    ..addAll(resp.dateTimes.map(_normalizeDateUtc));

  _loadingUnavailable = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loadingUnavailable = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ne mogu učitati zauzete termine: $e")),
      );
    }
  }

  bool _hasAnyBusyForDate(DateTime dateUtc) {
  for (final t in _buildDefaultSlots()) {
    if (_isSlotUnavailable(dateUtc, t)) return true;
  }
  return false;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Pregled uživo",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            _PropertyMiniHeader(property: widget.property),
            const SizedBox(height: 12),

            _Card(
              title: "Odaberi datum",
              subtitle: _loadingUnavailable
                  ? "Učitavam zauzete termine..."
                  : "Sivo = prošlo • Crveno = dan bez termina (sve zauzeto)",
              child: Column(
                children: [
                  _calendarHeader(),
                  const SizedBox(height: 10),
                  _weekdayRow(),
                  const SizedBox(height: 8),
                  _calendarGrid(),
                  const SizedBox(height: 10),
                  _MiniInfo(
                    label: "Odabrani datum",
                    value: _selectedDate == null
                        ? "—"
                        : _fmtDate(_selectedDate!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _Card(
              title: "Odaberi termin",
              subtitle: _selectedDate == null
                  ? "Prvo odaberi datum."
                  : "Zauzeti termini su onemogućeni.",
              child: _selectedDate == null
                  ? const _EmptyHint(text: "Odaberi datum da vidiš termine.")
                  : _timeSlots(),
            ),

            const SizedBox(height: 12),
            _summaryCard(),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  // ------------------ Calendar ------------------

  Widget _calendarHeader() {
    final monthName = DateFormat.MMMM("bs").format(_visibleMonth);
    final year = _visibleMonth.year;

    return Row(
      children: [
        _IconBtn(
          icon: Icons.chevron_left_rounded,
          onTap: () => setState(() {
            _visibleMonth = DateTime(
              _visibleMonth.year,
              _visibleMonth.month - 1,
              1,
            );
          }),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "${_capitalize(monthName)} $year",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ),
        const SizedBox(width: 8),
        _IconBtn(
          icon: Icons.chevron_right_rounded,
          onTap: () => setState(() {
            _visibleMonth = DateTime(
              _visibleMonth.year,
              _visibleMonth.month + 1,
              1,
            );
          }),
        ),
      ],
    );
  }

  Widget _weekdayRow() {
    const days = ["P", "U", "S", "Č", "P", "S", "N"];
    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _calendarGrid() {
    final firstDay = _visibleMonth;
    final daysInMonth = DateUtils.getDaysInMonth(firstDay.year, firstDay.month);

    final leading = firstDay.weekday - 1;
    final totalCells = leading + daysInMonth;
    final rows = (totalCells / 7.0).ceil();

    final today = _normalizeDateUtc(DateTime.now());

    return Column(
      children: List.generate(rows, (r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: List.generate(7, (c) {
              final idx = r * 7 + c;
              final dayNum = idx - leading + 1;

              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 44));
              }

              // ✅ date-only u UTC da nema pomjeranja dana
              final date = _normalizeDateUtc(
                DateTime.utc(firstDay.year, firstDay.month, dayNum),
              );

              final isPast = date.isBefore(today);

              final isSelected =
                  _selectedDate != null &&
                  _normalizeDateUtc(_selectedDate!) == date;

              final hasBusy = _unavailableDates.contains(date);

              final canTap = !_loadingUnavailable && !isPast;

              Color bg = Colors.white;
              Color fg = const Color(0xFF2F2F2F);
              BorderSide border = const BorderSide(color: Color(0x11000000));

              if (isPast) {
                fg = const Color(0xFFB0B0B0);
                bg = const Color(0xFFF2F3F4);
              } else if (hasBusy) {
                fg = const Color(0xFFE53935);
                bg = const Color(0xFFFFE8E8);
                border = const BorderSide(color: Color(0x33E53935));
              }

              if (isSelected) {
                bg = rentifyGreenDark;
                fg = Colors.white;
                border = BorderSide.none;
              }

              return Expanded(
                child: GestureDetector(
                  onTap: !canTap
                      ? null
                      : () {
                          setState(() {
                            _selectedDate = date;
                            _selectedTime = null;
                          });
                        },
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.fromBorderSide(border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dayNum.toString(),
                      style: TextStyle(fontWeight: FontWeight.w900, color: fg),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  // ------------------ Time slots ------------------

  Widget _timeSlots() {
    final slots = _buildDefaultSlots(); // 09:00 - 18:00

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: slots.map((t) {
        final disabled = _isSlotUnavailable(_selectedDate!, t);
        final selected =
            _selectedTime != null &&
            _selectedTime!.hour == t.hour &&
            _selectedTime!.minute == t.minute;

        Color bg = const Color(0xFFF6F7F8);
        Color fg = const Color(0xFF2F2F2F);
        BorderSide border = const BorderSide(color: Color(0x11000000));

        if (disabled) {
          bg = const Color(0xFFFFE8E8);
          fg = const Color(0xFFE53935);
          border = const BorderSide(color: Color(0x33E53935));
        }

        if (selected) {
          bg = rentifyGreenDark;
          fg = Colors.white;
          border = BorderSide.none;
        }

        return GestureDetector(
          onTap: disabled
              ? null
              : () => setState(() {
                  _selectedTime = t;
                }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.fromBorderSide(border),
            ),
            child: Text(
              _fmtTime(t),
              style: TextStyle(fontWeight: FontWeight.w900, color: fg),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<TimeOfDay> _buildDefaultSlots() {
    final List<TimeOfDay> out = [];
    for (int h = 9; h <= 18; h++) {
      out.add(TimeOfDay(hour: h, minute: 0));
    }
    return out;
  }

  bool _isSlotUnavailable(DateTime dateUtc, TimeOfDay t) {
    // dateUtc je već UTC date-only
    final dtUtc = DateTime.utc(
      dateUtc.year,
      dateUtc.month,
      dateUtc.day,
      t.hour,
      t.minute,
    );
    return _unavailableDateTimes.contains(_normalizeMinuteUtc(dtUtc));
  }

  bool _allSlotsBusyForDate(DateTime dateUtc) {
    final slots = _buildDefaultSlots();
    if (slots.isEmpty) return false;
    return slots.every((t) => _isSlotUnavailable(dateUtc, t));
  }

  // ------------------ Summary + Bottom ------------------

  Widget _summaryCard() {
    final dateText = _selectedDate == null ? "—" : _fmtDate(_selectedDate!);
    final timeText = _selectedTime == null ? "—" : _fmtTime(_selectedTime!);

    return _Card(
      title: "Sažetak",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Datum: $dateText",
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF2F2F2F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Termin: $timeText",
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF7A7A7A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final canReserve = _selectedDate != null && _selectedTime != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, -6),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: 48,
            child: OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: const BorderSide(color: Color(0x22000000)),
              ),
              child: const Text(
                "Reset",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: (!canReserve || _submitting) ? null : _reserve,
                style: ElevatedButton.styleFrom(
                  backgroundColor: rentifyGreenDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        "Rezerviši",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _reset() {
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    });
  }

  Future<void> _reserve() async {
    try {
      setState(() => _submitting = true);

      final userId = Session.userId;
      if (userId == null) throw Exception("Niste prijavljeni.");

      final d = _selectedDate!;
      final t = _selectedTime!;

      final dtUtc = DateTime.utc(d.year, d.month, d.day, t.hour, t.minute);

      final payload = <String, dynamic>{
        "userId": userId,
        "propertyId": widget.property.id,
        "dateAppointment": dtUtc.toIso8601String(),
      };

      await Provider.of<AppoitmentProvider>(
        context,
        listen: false,
      ).insert(payload);

      if (!mounted) return;

      setState(() => _submitting = false);

      await ConfirmDialogs.okConfirmation(
        context,
        title: "Pregled uživo",
        message:
            "Zahtjev za termin je uspješno poslan.\n\nNa sekciji Pregledi možete vidjeti da li je domaćin odobrio termin.",
      );

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);

      ConfirmDialogs.okConfirmation(
        context,
        title: "Greška",
        message: e.toString(),
      );
    }
  }

  // ------------------ helpers (UTC safe) ------------------

  DateTime _normalizeDateUtc(DateTime d) {
    final u = d.toUtc();
    return DateTime.utc(u.year, u.month, u.day);
  }

  DateTime _normalizeMinuteUtc(DateTime d) {
    final u = d.toUtc();
    return DateTime.utc(u.year, u.month, u.day, u.hour, u.minute);
  }

  String _fmtDate(DateTime d) => DateFormat("dd.MM.yyyy").format(d.toLocal());

  String _fmtTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/* ===================== Small UI Widgets (isto kao kod tebe) ===================== */

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF7A7A7A)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF7A7A7A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyMiniHeader extends StatelessWidget {
  const _PropertyMiniHeader({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    final title = (property.name ?? "").trim();
    final city = (property.city ?? "").trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 6),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFF2F3F4),
            ),
            child: const Icon(Icons.home_rounded, color: Color(0xFF5F9F3B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? "Nekretnina" : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  city.isEmpty ? "—" : city,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, this.subtitle, required this.child});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 6),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF2F2F2F),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF7A7A7A),
                height: 1.25,
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x11000000)),
        ),
        child: Icon(icon, color: const Color(0xFF2F2F2F)),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF7A7A7A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF2F2F2F),
            ),
          ),
        ],
      ),
    );
  }
}
