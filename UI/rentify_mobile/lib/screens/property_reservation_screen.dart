import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rentify_mobile/models/property.dart';

enum ReservationType { monthly, shortStay }

class PropertyReservationUniversalScreen extends StatefulWidget {
  const PropertyReservationUniversalScreen({
    super.key,
    required this.property,
    required this.type,
    this.unavailableDates = const [],
  });

  final Property property;
  final ReservationType type;

  /// Za "colored calendar": listu popuniš sa API-a (zauzeti dani).
  /// Ovdje je demo.
  final List<DateTime> unavailableDates;

  @override
  State<PropertyReservationUniversalScreen> createState() =>
      _PropertyReservationUniversalScreenState();
}

class _PropertyReservationUniversalScreenState extends State<PropertyReservationUniversalScreen> {
  // Rentify theme
  static const rentifyGreenDark = Color(0xFF5F9F3B);

  // --- MONTHLY state ---
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // --- SHORT STAY state ---
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _start;
  DateTime? _end;

  late final Set<DateTime> _unavailable; // normalized (yyyy-mm-dd)

  @override
  void initState() {
    super.initState();

    _unavailable = widget.unavailableDates
        .map(_normalizeDate)
        .toSet();

    // (Demo) ako nije poslano ništa, ubaci par zauzetih dana čisto da vidiš crveno
    if (_unavailable.isEmpty && widget.type == ReservationType.shortStay) {
      final now = DateTime.now();
      _unavailable.addAll([
        _normalizeDate(now.add(const Duration(days: 2))),
        _normalizeDate(now.add(const Duration(days: 3))),
        _normalizeDate(now.add(const Duration(days: 7))),
        _normalizeDate(now.add(const Duration(days: 11))),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == ReservationType.monthly
        ? "Mjesečna kirija"
        : "Kratki boravak";

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            _PropertyMiniHeader(property: widget.property),
            const SizedBox(height: 12),

            if (widget.type == ReservationType.monthly)
              _monthlyPickerCard()
            else
              _shortStayCalendarCard(),

            const SizedBox(height: 12),
            _summaryCard(),
          ],
        ),
      ),

      bottomNavigationBar: _bottomBar(),
    );
  }

  // ------------------ MONTHLY UI ------------------

  Widget _monthlyPickerCard() {
    final months = List.generate(12, (i) => i + 1);
    final years = List.generate(8, (i) => DateTime.now().year + i); // 8 godina unaprijed

    return _Card(
      title: "Odaberi period",
      child: Row(
        children: [
          Expanded(
            child: _Dropdown<int>(
              label: "Mjesec",
              value: _selectedMonth,
              items: months
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(DateFormat.MMMM("bs").format(DateTime(2025, m, 1))),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedMonth = v ?? _selectedMonth),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Dropdown<int>(
              label: "Godina",
              value: _selectedYear,
              items: years
                  .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                  .toList(),
              onChanged: (v) => setState(() => _selectedYear = v ?? _selectedYear),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ SHORT STAY UI ------------------

  Widget _shortStayCalendarCard() {
    return _Card(
      title: "Odaberi datume",
      subtitle:
          "Crveno = zauzeto • Sivo = prošlo • Odaberi od–do (slobodne dane).",
      child: Column(
        children: [
          _calendarHeader(),
          const SizedBox(height: 10),
          _weekdayRow(),
          const SizedBox(height: 8),
          _calendarGrid(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniInfo(
                  label: "Od",
                  value: _start == null ? "—" : _fmt(_start!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniInfo(
                  label: "Do",
                  value: _end == null ? "—" : _fmt(_end!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calendarHeader() {
    final monthName = DateFormat.MMMM("bs").format(_visibleMonth);
    final year = _visibleMonth.year;

    return Row(
      children: [
        _IconBtn(
          icon: Icons.chevron_left_rounded,
          onTap: () => setState(() {
            _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
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
            _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
          }),
        ),
      ],
    );
  }

  Widget _weekdayRow() {
    const days = ["P", "U", "S", "Č", "P", "S", "N"];
    return Row(
      children: days
          .map((d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7A7A7A),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _calendarGrid() {
    final firstDay = _visibleMonth;
    final daysInMonth = DateUtils.getDaysInMonth(firstDay.year, firstDay.month);

    final leading = firstDay.weekday - 1; 

    final totalCells = leading + daysInMonth;
    final rows = ((totalCells) / 7.0).ceil();
    final cellCount = rows * 7;

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

              final date = _normalizeDate(DateTime(firstDay.year, firstDay.month, dayNum));
              final isPast = date.isBefore(today);
              final isUnavailable = _unavailable.contains(date);

              final isSelectedStart = _start != null && _normalizeDate(_start!) == date;
              final isSelectedEnd = _end != null && _normalizeDate(_end!) == date;
              final inRange = _start != null &&
                  _end != null &&
                  !date.isBefore(_normalizeDate(_start!)) &&
                  !date.isAfter(_normalizeDate(_end!));

              final canTap = !isPast && !isUnavailable;

              Color bg = Colors.white;
              Color fg = const Color(0xFF2F2F2F);
              BorderSide border = const BorderSide(color: Color(0x11000000));

              // colored theme rules
              if (isPast) {
                fg = const Color(0xFFB0B0B0);
                bg = const Color(0xFFF2F3F4);
              } else if (isUnavailable) {
                fg = const Color(0xFFE53935); // red text
                bg = const Color(0xFFFFE8E8); // light red bg
                border = const BorderSide(color: Color(0x33E53935));
              }

              if (inRange && _start != null && _end != null) {
                bg = const Color(0x1A5F9F3B); // light green
                border = const BorderSide(color: Color(0x335F9F3B));
              }

              if (isSelectedStart || isSelectedEnd) {
                bg = rentifyGreenDark;
                fg = Colors.white;
                border = BorderSide.none;
              }

              return Expanded(
                child: GestureDetector(
                  onTap: !canTap ? null : () => _onTapDate(date),
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

  void _onTapDate(DateTime date) {
    // Prvi klik -> start
    if (_start == null || (_start != null && _end != null)) {
      setState(() {
        _start = date;
        _end = null;
      });
      return;
    }

    // Drugi klik -> end
    if (_start != null && _end == null) {
      // Ako klikne prije start -> zamijeni start
      if (date.isBefore(_normalizeDate(_start!))) {
        setState(() => _start = date);
        return;
      }

      // Provjeri da li range sadrži zauzete dane
      if (_rangeHasUnavailable(_normalizeDate(_start!), date)) {
        // Ne prikazujem “crash”, samo mali snack
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Odabrani period sadrži zauzete dane."),
          ),
        );
        return;
      }

      setState(() => _end = date);
    }
  }

  bool _rangeHasUnavailable(DateTime start, DateTime end) {
    DateTime d = start;
    while (!d.isAfter(end)) {
      if (_unavailable.contains(d)) return true;
      d = d.add(const Duration(days: 1));
    }
    return false;
  }

  // ------------------ SUMMARY + BOTTOM ------------------

  Widget _summaryCard() {
    final priceMonth = widget.property.pricePerMonth;
    final priceDay = widget.property.pricePerDay;

    String line1;
    String line2;

    if (widget.type == ReservationType.monthly) {
      line1 = "Period: ${_selectedMonth.toString().padLeft(2, '0')}.${_selectedYear}";
      line2 = priceMonth == null ? "Cijena: —" : "Cijena: ${priceMonth.toStringAsFixed(0)} KM / mjesec";
    } else {
      final nights = _start == null || _end == null
          ? null
          : _end!.difference(_start!).inDays; // od–do, npr 10->12 = 2 noći
      line1 = "Datumi: ${_start == null ? "—" : _fmt(_start!)}  →  ${_end == null ? "—" : _fmt(_end!)}";
      if (nights == null) {
        line2 = "Cijena: —";
      } else {
        final p = (priceDay ?? 0);
        final total = p * nights;
        line2 = priceDay == null
            ? "Cijena: —"
            : "Noći: $nights • Ukupno: ${total.toStringAsFixed(0)} KM";
      }
    }

    return _Card(
      title: "Sažetak",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(line1,
              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2F2F2F))),
          const SizedBox(height: 6),
          Text(line2,
              style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF7A7A7A))),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final canContinue = widget.type == ReservationType.monthly
        ? true
        : (_start != null && _end != null);

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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: const BorderSide(color: Color(0x22000000)),
              ),
              child: const Text("Reset", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: canContinue ? _continue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: rentifyGreenDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text("Nastavi", style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _reset() {
    setState(() {
      _selectedMonth = DateTime.now().month;
      _selectedYear = DateTime.now().year;

      _start = null;
      _end = null;
      _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    });
  }

  void _continue() {
    // Ovdje kasnije šalješ API request.
    // Za demo: samo zatvori i vrati payload.

    if (widget.type == ReservationType.monthly) {
      Navigator.pop(context, {
        "type": "monthly",
        "month": _selectedMonth,
        "year": _selectedYear,
      });
    } else {
      Navigator.pop(context, {
        "type": "shortStay",
        "start": _start?.toIso8601String(),
        "end": _end?.toIso8601String(),
      });
    }
  }

  // ------------------ helpers ------------------

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  String _fmt(DateTime d) => DateFormat("dd.MM.yyyy").format(d);

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/* ===================== Small UI Widgets ===================== */

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
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, color: Color(0xFF2F2F2F))),
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

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF6F7F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
        ),
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
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: Color(0xFF7A7A7A))),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, color: Color(0xFF2F2F2F))),
        ],
      ),
    );
  }
}