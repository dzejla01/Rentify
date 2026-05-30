import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/dialogs/confirmation_dialogs.dart';
import 'package:rentify_mobile/helper/date_helper.dart';
import 'package:rentify_mobile/helper/snackBar_helper.dart';
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

enum DayAvailability { free, partial, full }

class _PropertyAppointmentUniversalScreenState
    extends State<PropertyAppointmentUniversalScreen> {
  static const rentifyGreenDark = Color(0xFF5F9F3B);

  static const List<String> _timeSlots = [
    "09:00",
    "10:00",
    "11:00",
    "12:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00",
    "18:00",
  ];

  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDate;
  String? _selectedTime;

  bool _loadingUnavailable = false;
  bool _submitting = false;

  final Set<DateTime> _unavailableDateTimes = {};
  final Set<DateTime> _unavailableDates = {};
  final Map<DateTime, Set<String>> _unavailableSlotsByDay = {};

  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
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

      final normalizedDateTimes = <DateTime>{};
      final normalizedDates = <DateTime>{};
      final unavailableSlotsByDay = <DateTime, Set<String>>{};

      for (final dt in resp.dateTimes) {
        final local = dt.toLocal();
        final normalizedMinute = _normalizeMinute(local);
        final normalizedDay = _normalizeDate(local);
        final timeKey =
            "${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";

        normalizedDateTimes.add(normalizedMinute);
        normalizedDates.add(normalizedDay);
        unavailableSlotsByDay.putIfAbsent(normalizedDay, () => <String>{}).add(timeKey);
      }

      setState(() {
        _unavailableDateTimes
          ..clear()
          ..addAll(normalizedDateTimes);

        _unavailableDates
          ..clear()
          ..addAll(normalizedDates);

        _unavailableSlotsByDay
          ..clear()
          ..addAll(unavailableSlotsByDay);

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

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _normalizeMinute(DateTime d) =>
      DateTime(d.year, d.month, d.day, d.hour, d.minute);

  String _fmtDate(DateTime d) => DateFormat("dd.MM.yyyy").format(d);

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  DayAvailability _getDayAvailability(DateTime date) {
    final day = _normalizeDate(date);
    final booked = _unavailableSlotsByDay[day]?.length ?? 0;
    const totalSlots = 10;

    if (booked >= totalSlots) return DayAvailability.full;
    if (booked > 0) return DayAvailability.partial;
    return DayAvailability.free;
  }

  bool _isSlotUnavailable(DateTime day, String slot) {
    final normalizedDay = _normalizeDate(day);
    return _unavailableSlotsByDay[normalizedDay]?.contains(slot) ?? false;
  }

  void _onTapDate(DateTime date) {
    final normalized = _normalizeDate(date);
    final dayStatus = _getDayAvailability(normalized);

    if (dayStatus == DayAvailability.full) return;

    setState(() {
      _selectedDate = normalized;
      _selectedTime = null;
      _fieldErrors.remove("dateAppointment");
      _fieldErrors.remove("timeAppointment");
    });
  }

  void _onTapTime(String slot) {
    if (_selectedDate == null) return;
    if (_isSlotUnavailable(_selectedDate!, slot)) return;

    setState(() {
      _selectedTime = slot;
      _fieldErrors.remove("timeAppointment");
    });
  }

  bool _validateForm() {
    final errors = <String, String>{};

    if (_selectedDate == null) {
      errors["dateAppointment"] = "Datum termina je obavezan.";
    }

    if (_selectedTime == null) {
      errors["timeAppointment"] = "Vrijeme termina je obavezno.";
    }

    if (_selectedDate != null && _selectedTime != null) {
      final parts = _selectedTime!.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final selectedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        hour,
        minute,
      );

      if (_unavailableDateTimes.contains(_normalizeMinute(selectedDateTime))) {
        errors["timeAppointment"] = "Odabrani termin više nije dostupan.";
      }
    }

    setState(() {
      _fieldErrors = errors;
    });

    return errors.isEmpty;
  }

  Future<void> _submit() async {
    if (!_validateForm()) return;

    try {
      setState(() => _submitting = true);

      final userId = Session.userId;
      if (userId == null) {
        await ConfirmDialogs.okConfirmation(
          context,
          title: "Greška",
          message: "Niste prijavljeni.",
        );
        setState(() => _submitting = false);
        return;
      }

      final parts = _selectedTime!.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final appointmentLocal = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        hour,
        minute,
      );

      final payload = <String, dynamic>{
        "userId": userId,
        "propertyId": widget.property.id,
        "dateAppointment": appointmentLocal.toUtc().toIso8601String(),
        "statusId": 1,
      };

      await Provider.of<AppoitmentProvider>(
        context,
        listen: false,
      ).insert(payload);

      if (!mounted) return;
      setState(() => _submitting = false);

      await ConfirmDialogs.okConfirmation(
        context,
        title: "Termin",
        message:
            "Zahtjev za termin je uspješno poslan.\n\nNa sekciji Termini možete vidjeti da li je vlasnik odobrio vaš termin.",
      );

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      SnackbarHelper.showError(context, e.toString());
    }
  }

  void _reset() {
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _fieldErrors = {};
      _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    });
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
            _calendarCard(),
            const SizedBox(height: 12),
            _timeSlotsCard(),
            if (_fieldErrors.isNotEmpty) ...[
              const SizedBox(height: 12),
              _validationCard(),
            ],
            const SizedBox(height: 12),
            _summaryCard(),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _calendarCard() {
    return _Card(
      title: "Odaberi datum",
      subtitle: _loadingUnavailable
          ? "Učitavam zauzete termine..."
          : "Crveno = svi termini zauzeti • Žuto = djelimično popunjeno • Sivo = prošlo",
      child: Column(
        children: [
          _calendarHeader(),
          const SizedBox(height: 10),
          _weekdayRow(),
          const SizedBox(height: 8),
          _calendarGrid(),
          const SizedBox(height: 12),
          _MiniInfo(
            label: "Odabrani datum",
            value: _selectedDate == null ? "—" : _fmtDate(_selectedDate!),
          ),
        ],
      ),
    );
  }

  Widget _timeSlotsCard() {
    return _Card(
      title: "Odaberi termin",
      subtitle: _selectedDate == null
          ? "Prvo odaberite datum."
          : "Zauzeti termini su onemogućeni.",
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _timeSlots.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
        ),
        itemBuilder: (context, index) {
          final slot = _timeSlots[index];
          final isUnavailable = _selectedDate == null
              ? false
              : _isSlotUnavailable(_selectedDate!, slot);
          final isSelected = _selectedTime == slot;
          final canTap = _selectedDate != null && !isUnavailable;

          Color bg = Colors.white;
          Color fg = const Color(0xFF2F2F2F);
          BorderSide border = const BorderSide(color: Color(0x11000000));

          if (_selectedDate == null) {
            bg = const Color(0xFFF2F3F4);
            fg = const Color(0xFFB0B0B0);
          } else if (isUnavailable) {
            bg = const Color(0xFFFFF3E0);
            fg = const Color(0xFFEF6C00);
            border = const BorderSide(color: Color(0x33EF6C00));
          }

          if (isSelected) {
            bg = rentifyGreenDark;
            fg = Colors.white;
            border = BorderSide.none;
          }

          return GestureDetector(
            onTap: canTap ? () => _onTapTime(slot) : null,
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.fromBorderSide(border),
              ),
              alignment: Alignment.center,
              child: Text(
                slot,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _calendarHeader() {
    final monthName = DateFormat.MMMM("bs").format(_visibleMonth);
    final year = _visibleMonth.year;

    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final canGoPrev = !_visibleMonth.isAtSameMomentAs(currentMonth) &&
        !_visibleMonth.isBefore(currentMonth);

    return Row(
      children: [
        _IconBtn(
          icon: Icons.chevron_left_rounded,
          onTap: !canGoPrev
              ? () {}
              : () => setState(() {
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
    final today = _normalizeDate(DateTime.now());

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

              final date = _normalizeDate(
                DateTime(firstDay.year, firstDay.month, dayNum),
              );

              final isPast = date.isBefore(today);
              final dayStatus = _getDayAvailability(date);
              final isSelected =
                  _selectedDate != null && _normalizeDate(_selectedDate!) == date;

              final isFull = dayStatus == DayAvailability.full;
              final isPartial = dayStatus == DayAvailability.partial;
              final canTap = !_loadingUnavailable && !isPast && !isFull;

              Color bg = Colors.white;
              Color fg = const Color(0xFF2F2F2F);
              BorderSide border = const BorderSide(color: Color(0x11000000));

              if (isPast) {
                fg = const Color(0xFFB0B0B0);
                bg = const Color(0xFFF2F3F4);
              } else if (isFull) {
                fg = const Color(0xFFE53935);
                bg = const Color(0xFFFFE8E8);
                border = const BorderSide(color: Color(0x33E53935));
              } else if (isPartial) {
                fg = const Color(0xFFEF6C00);
                bg = const Color(0xFFFFF3E0);
                border = const BorderSide(color: Color(0x33EF6C00));
              }

              if (isSelected) {
                bg = rentifyGreenDark;
                fg = Colors.white;
                border = BorderSide.none;
              }

              return Expanded(
                child: GestureDetector(
                  onTap: canTap ? () => _onTapDate(date) : null,
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
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: fg,
                      ),
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

  Widget _summaryCard() {
    final line1 = _selectedDate == null
        ? "Datum: —"
        : "Datum: ${_fmtDate(_selectedDate!)}";

    final line2 = _selectedTime == null
        ? "Termin: —"
        : "Termin: $_selectedTime";

    return _Card(
      title: "Sažetak",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line1,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF2F2F2F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            line2,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF7A7A7A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _validationCard() {
    final values = _fieldErrors.values.toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33D32F2F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Provjerite unesene podatke",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFFD32F2F),
            ),
          ),
          const SizedBox(height: 8),
          ...values.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                "• $e",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7A1C1C),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
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
                onPressed: _submitting ? null : _submit,
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
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Pošalji zahtjev",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
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
    final title = property.name.trim();
    final city = (property.city?.name ?? "").trim();

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
