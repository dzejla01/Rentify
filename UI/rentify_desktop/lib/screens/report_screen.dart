import 'dart:io';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rentify_desktop/helper/snackbar_helper.dart';
import 'package:rentify_desktop/models/best_owner_by_year.dart';
import 'package:rentify_desktop/models/monthly_income.dart';
import 'package:rentify_desktop/models/property_income.dart';
import 'package:rentify_desktop/providers/report_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/utils/session.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

enum _ReportTab { income, bestOwner }

class _ReportScreenState extends State<ReportScreen> {
  static const Color _green = Color(0xFF5F9F3B);
  static const Color _greenDark = Color(0xFF466F2C);
  static const Color _greenSoft = Color(0xFFEAF6E5);
  static const Color _greenSoft2 = Color(0xFFF3FAEF);
  static const Color _border = Color(0xFFDFE6DA);
  static const Color _text = Color(0xFF1F2A1F);
  static const Color _muted = Color(0xFF6B7280);

  final _api = IncomeReportApi();

  bool _loading = false;
  _ReportTab _selectedTab = _ReportTab.income;

  final ScrollController _incomeScrollController = ScrollController();
  final ScrollController _bestOwnerScrollController = ScrollController();
  final ScrollController _trendHorizontalController = ScrollController();

  // INCOME
  List<MonthlyIncome> _monthly = [];
  List<PropertyIncome> _byProperty = [];
  int? _selectedIncomeYear;
  int? _selectedIncomeMonth;

  // BEST OWNER
  final List<int> _yearOptions = const [2025, 2026];
  int? _selectedYear = 2026;
  BestOwnerByYear? _bestOwner;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  @override
  void dispose() {
    _incomeScrollController.dispose();
    _bestOwnerScrollController.dispose();
    _trendHorizontalController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    if (_loading) return;

    setState(() => _loading = true);
    try {
      await _loadIncomeInitial();
      await _loadBestOwner();
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadIncomeInitial() async {
    final ownerId = Session.userId!;

    final report = await _api.getIncomeReport(ownerId: ownerId, monthsBack: 24);

    final sorted = [...report.monthly]
      ..sort((a, b) {
        final ay = a.year * 100 + a.month;
        final by = b.year * 100 + b.month;
        return ay.compareTo(by);
      });

    setState(() {
      _monthly = sorted;
    });

    // default: zadnji dostupan mjesec
    if (sorted.isNotEmpty) {
      final last = sorted.last;
      _selectedIncomeYear = last.year;
      _selectedIncomeMonth = last.month;
      await _loadSelectedIncomeByProperty();
    } else {
      setState(() {
        _selectedIncomeYear = 2026;
        _selectedIncomeMonth = 1;
        _byProperty = [];
      });
    }
  }

  Future<void> _loadSelectedIncomeByProperty() async {
    if (_selectedIncomeYear == null || _selectedIncomeMonth == null) return;

    final ownerId = Session.userId!;

    final report = await _api.getIncomeReport(
      ownerId: ownerId,
      monthsBack: 24,
      year: _selectedIncomeYear,
      month: _selectedIncomeMonth,
    );

    setState(() {
      _byProperty = report.byProperty;
    });
  }

  Future<void> _loadBestOwner() async {
    if (_selectedYear == null) return;

    final result = await _api.getBestOwnerByYear(year: _selectedYear!);

    setState(() {
      _bestOwner = result;
    });
  }

  MonthlyIncome? get _selectedMonthlyIncome {
    if (_selectedIncomeYear == null || _selectedIncomeMonth == null)
      return null;

    try {
      return _monthly.firstWhere(
        (m) => m.year == _selectedIncomeYear && m.month == _selectedIncomeMonth,
      );
    } catch (_) {
      return null;
    }
  }

  double get _selectedMonthTotal =>
      _byProperty.fold<double>(0, (a, b) => a + b.total);

  String _km(num v) => "${v.toStringAsFixed(0)} KM";

  List<int> get _incomeYearOptions => const [2025, 2026];

  List<int> get _incomeMonthOptions {
    if (_selectedIncomeYear == 2025) {
      return List.generate(12, (i) => i + 1);
    }
    if (_selectedIncomeYear == 2026) {
      return List.generate(4, (i) => i + 1);
    }
    return [];
  }

  String _monthLabel(int month) {
    const names = [
      "Januar",
      "Februar",
      "Mart",
      "April",
      "Maj",
      "Juni",
      "Juli",
      "August",
      "Septembar",
      "Oktobar",
      "Novembar",
      "Decembar",
    ];

    if (month < 1 || month > 12) return month.toString();
    return names[month - 1];
  }

  Future<void> _printCurrentReport() async {
    if (_selectedTab == _ReportTab.income) {
      await _printIncomeReport();
    } else {
      await _printBestOwnerReport();
    }
  }

  Future<void> _printIncomeReport() async {
    final selected = _selectedMonthlyIncome;

    if (selected == null) {
      SnackbarHelper.showInfo(context, "Nema podataka za printanje.");
      return;
    }

    final label =
        "${selected.year}_${selected.month.toString().padLeft(2, '0')}";

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Sačuvaj PDF izvjestaj',
      fileName: 'Rentify_Izvjestaj_Prihod_$label.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (path == null) return;

    try {
      setState(() => _loading = true);

      final bytes = await _buildIncomePdfBytes(
        monthly: _monthly,
        byProperty: _byProperty,
        selected: selected,
        totalSelected: _selectedMonthTotal,
      );

      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, "Ne mogu napraviti PDF: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _printBestOwnerReport() async {
    if (_selectedYear == null) {
      SnackbarHelper.showInfo(context, "Odaberite godinu");
      return;
    }

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Sačuvaj PDF izvještaj',
      fileName: 'Rentify_NajboljiOwner_${_selectedYear!}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (path == null) return;

    try {
      setState(() => _loading = true);

      final bytes = await _buildBestOwnerPdfBytes(
        year: _selectedYear!,
        bestOwner: _bestOwner,
      );

      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, "Ne mogu napraviti PDF: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<List<int>> _buildIncomePdfBytes({
    required List<MonthlyIncome> monthly,
    required List<PropertyIncome> byProperty,
    required MonthlyIncome selected,
    required double totalSelected,
  }) async {
    final doc = pw.Document();

    final now = DateTime.now();
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');

    String km(num v) => "${v.toStringAsFixed(0)} KM";

    final monthlySorted = [...monthly]
      ..sort(
        (a, b) => (a.year * 100 + a.month).compareTo(b.year * 100 + b.month),
      );

    final byPropertySorted = [...byProperty]
      ..sort((a, b) => b.total.compareTo(a.total));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Rentify Izvjestaj prihoda",
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    "Generisano: ${dateFmt.format(now)}",
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.green200),
                ),
                child: pw.Text(
                  "Period: ${_monthLabel(selected.month)} ${selected.year}",
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(color: PdfColors.green200),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Ukupno (odabrani mjesec)",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  km(totalSelected),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green800,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            "Trend prihoda",
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            headers: const ["Mjesec", "Ukupno"],
            data: monthlySorted
                .map((m) => ["${_monthLabel(m.month)} ${m.year}", km(m.total)])
                .toList(),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            "Prihod po nekretnini (${_monthLabel(selected.month)} ${selected.year})",
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (byPropertySorted.isEmpty)
            pw.Text("Nema podataka za odabrani mjesec.")
          else
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
              },
              headers: const ["Nekretnina", "Iznos", "Udio"],
              data: byPropertySorted.map((p) {
                final pct = totalSelected == 0
                    ? 0
                    : (p.total / totalSelected) * 100.0;
                return [
                  p.propertyName,
                  km(p.total),
                  "${pct.toStringAsFixed(0)}%",
                ];
              }).toList(),
            ),
        ],
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            "Stranica ${context.pageNumber} / ${context.pagesCount}",
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ),
      ),
    );

    return doc.save();
  }

  Future<List<int>> _buildBestOwnerPdfBytes({
    required int year,
    required BestOwnerByYear? bestOwner,
  }) async {
    final doc = pw.Document();
    final now = DateTime.now();
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Rentify Izvještaj najboljeg vlasnika",
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    "Generisano: ${dateFmt.format(now)}",
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.green200),
                ),
                child: pw.Text(
                  "Godina: $year",
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          if (bestOwner == null)
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Text(
                "Za odabranu godinu nema podataka o rezervacijama.",
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            )
          else
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                borderRadius: pw.BorderRadius.circular(14),
                border: pw.Border.all(color: PdfColors.green200),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Najbolji vlasnik godine",
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    bestOwner.ownerName,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    "Ukupan broj rezervacija: ${bestOwner.totalReservations}",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 18),
                  pw.Table.fromTextArray(
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    cellAlignment: pw.Alignment.centerLeft,
                    cellPadding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    headers: const ["Polje", "Vrijednost"],
                    data: [
                      ["Godina", bestOwner.year.toString()],
                      ["Ime vlasnika", bestOwner.ownerName],
                      [
                        "Ukupno rezervacija",
                        bestOwner.totalReservations.toString(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
        ],
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            "Stranica ${context.pageNumber} / ${context.pagesCount}",
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ),
      ),
    );

    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel = _selectedMonthlyIncome == null
        ? "-"
        : "${_monthLabel(_selectedMonthlyIncome!.month)} ${_selectedMonthlyIncome!.year}";

    final propertyEntries =
        _byProperty.map((e) => MapEntry(e.propertyName, e.total)).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final lineData = _monthly.map((e) => e.total).toList();
    final lineLabels = _monthly
        .map((e) => "${e.month.toString().padLeft(2, '0')}/${e.year}")
        .toList();

    final kpiValue = _selectedMonthTotal;

    return RentifyBasePage(
      title: "Izvještaji",
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopSwitchBar(
                  selectedTab: _selectedTab,
                  onChanged: (tab) {
                    setState(() => _selectedTab = tab);
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _KpiCard(
                        title: _selectedTab == _ReportTab.income
                            ? "Ukupni mjesečni prihod"
                            : "Najbolji vlasnik u godini",
                        value: _selectedTab == _ReportTab.income
                            ? _km(kpiValue)
                            : (_bestOwner?.ownerName ?? "Nema podataka"),
                        subtitle: _selectedTab == _ReportTab.income
                            ? "Period: $selectedLabel"
                            : (_bestOwner == null
                                  ? "Za odabranu godinu nema podataka."
                                  : "${_bestOwner!.totalReservations} rezervacija u ${_bestOwner!.year}. godini"),
                        icon: _selectedTab == _ReportTab.income
                            ? Icons.payments_rounded
                            : Icons.workspace_premium_rounded,
                        accent: _selectedTab == _ReportTab.income
                            ? _green
                            : _greenDark,
                        accentSoft: _selectedTab == _ReportTab.income
                            ? _greenSoft
                            : _greenSoft2,
                        border: _border,
                        text: _text,
                        muted: _muted,
                      ),
                    ),
                    const SizedBox(width: 14),

                    if (_selectedTab == _ReportTab.income)
                      _FilterCard(
                        border: _border,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: _green,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Godina:",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _text,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 110,
                              child: DropdownButtonFormField<int>(
                                value: _selectedIncomeYear,
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: _border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: _border,
                                    ),
                                  ),
                                ),
                                items: _incomeYearOptions
                                    .map(
                                      (y) => DropdownMenuItem(
                                        value: y,
                                        child: Text(
                                          y.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) async {
                                  if (v == null) return;
                                  setState(() {
                                    _selectedIncomeYear = v;
                                    _selectedIncomeMonth = v == 2025 ? 1 : 1;
                                  });

                                  try {
                                    setState(() => _loading = true);
                                    await _loadSelectedIncomeByProperty();
                                  } catch (e) {
                                    if (!mounted) return;
                                    SnackbarHelper.showError(context, e.toString());
                                  } finally {
                                    if (mounted) {
                                      setState(() => _loading = false);
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Mjesec:",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _text,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: DropdownButtonFormField<int>(
                                value: _selectedIncomeMonth,
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: _border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: _border,
                                    ),
                                  ),
                                ),
                                items: _incomeMonthOptions
                                    .map(
                                      (m) => DropdownMenuItem(
                                        value: m,
                                        child: Text(
                                          _monthLabel(m),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) async {
                                  if (v == null) return;
                                  setState(() => _selectedIncomeMonth = v);
                                  try {
                                    setState(() => _loading = true);
                                    await _loadSelectedIncomeByProperty();
                                  } catch (e) {
                                    if (!mounted) return;
                                    SnackbarHelper.showError(context, e.toString());
                                  } finally {
                                    if (mounted) {
                                      setState(() => _loading = false);
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_selectedTab == _ReportTab.bestOwner)
                      _FilterCard(
                        border: _border,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.event_rounded,
                              color: _greenDark,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Godina:",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _text,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 130,
                              child: DropdownButtonFormField<int>(
                                value: _selectedYear,
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: _border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: _border,
                                    ),
                                  ),
                                ),
                                items: _yearOptions
                                    .map(
                                      (y) => DropdownMenuItem(
                                        value: y,
                                        child: Text(
                                          y.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) async {
                                  if (v == null) return;
                                  setState(() => _selectedYear = v);
                                  try {
                                    setState(() => _loading = true);
                                    await _loadBestOwner();
                                  } catch (e) {
                                    if (!mounted) return;
                                    SnackbarHelper.showError(context, e.toString());
                                  } finally {
                                    if (mounted) {
                                      setState(() => _loading = false);
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(width: 14),

                    ElevatedButton.icon(
                      onPressed: _loading ? null : _printCurrentReport,
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: Text(
                        _selectedTab == _ReportTab.income
                            ? "Printaj Izvještaj"
                            : "Printaj najboljeg vlasnika ",
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTab == _ReportTab.income
                            ? _green
                            : _greenDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: _selectedTab == _ReportTab.income
                      ? Scrollbar(
                          controller: _incomeScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _incomeScrollController,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 380,
                                  child: _SectionCard(
                                    title: "Trend prihoda (mjeseci)",
                                    subtitle:
                                        "Line chart • ukupni prihod po mjesecima",
                                    border: _border,
                                    headerColor: _greenSoft,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        14,
                                        16,
                                        16,
                                      ),
                                      child: Scrollbar(
                                        controller: _trendHorizontalController,
                                        thumbVisibility: true,
                                        notificationPredicate: (_) => true,
                                        child: SingleChildScrollView(
                                          controller:
                                              _trendHorizontalController,
                                          scrollDirection: Axis.horizontal,
                                          child: SizedBox(
                                            width: math.max(
                                              MediaQuery.of(
                                                    context,
                                                  ).size.width -
                                                  120,
                                              lineData.length * 110,
                                            ),
                                            child: _LineChart(
                                              data: lineData,
                                              labels: lineLabels,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 520,
                                  child: _SectionCard(
                                    title: "Prihod po nekretnini",
                                    subtitle:
                                        "Pie chart • raspodjela za $selectedLabel",
                                    border: _border,
                                    headerColor: _greenSoft,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        14,
                                        16,
                                        16,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Ukupno",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: _text,
                                                ),
                                              ),
                                              Text(
                                                _km(_selectedMonthTotal),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  color: _green,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            height: 180,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: _PieChart(
                                                    values: propertyEntries
                                                        .map((e) => e.value)
                                                        .toList(),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: _LegendList(
                                                    items: propertyEntries
                                                        .map(
                                                          (e) => _LegendItem(
                                                            e.key,
                                                            e.value,
                                                          ),
                                                        )
                                                        .toList(),
                                                    total: _selectedMonthTotal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Divider(
                                            height: 1,
                                            color: _border,
                                          ),
                                          const SizedBox(height: 10),
                                          Expanded(
                                            child: propertyEntries.isEmpty
                                                ? const Center(
                                                    child: Text(
                                                      "Nema podataka.",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  )
                                                : ListView.separated(
                                                    itemCount:
                                                        propertyEntries.length,
                                                    separatorBuilder: (_, __) =>
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                    itemBuilder: (context, i) {
                                                      final e =
                                                          propertyEntries[i];
                                                      final pct =
                                                          _selectedMonthTotal ==
                                                              0
                                                          ? 0
                                                          : (e.value /
                                                                    _selectedMonthTotal) *
                                                                100;

                                                      return Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 14,
                                                              vertical: 12,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: _greenSoft,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                14,
                                                              ),
                                                          border: Border.all(
                                                            color: _border,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .home_rounded,
                                                              size: 18,
                                                              color: _green,
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                e.key,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  color: _text,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              "${_km(e.value)} • ${pct.toStringAsFixed(0)}%",
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: _muted,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Scrollbar(
                          controller: _bestOwnerScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _bestOwnerScrollController,
                            child: SizedBox(
                              height: 560,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: _SectionCard(
                                      title: "Šampion godine",
                                      subtitle: "Vlasnik sa najviše rezervacija",
                                      border: _border,
                                      headerColor: _greenSoft2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFF7FCF4),
                                                Color(0xFFEAF6E5),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            border: Border.all(color: _border),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x12000000),
                                                blurRadius: 18,
                                                offset: Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(26),
                                          child: _bestOwner == null
                                              ? Center(
                                                  child: Text(
                                                    "Za godinu ${_selectedYear ?? '-'} nema podataka.",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: _text,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                )
                                              : Column(
                                                  children: [
                                                    Container(
                                                      width: 82,
                                                      height: 82,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: _greenDark
                                                              .withOpacity(
                                                                0.28,
                                                              ),
                                                        ),
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .emoji_events_rounded,
                                                        color: _greenDark,
                                                        size: 42,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 18),
                                                    Text(
                                                      "Najbolji vlasnik za ${_bestOwner!.year}. godinu",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: _muted,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text(
                                                      _bestOwner!.ownerName,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: _text,
                                                        fontSize: 28,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 14),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 18,
                                                            vertical: 10,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              999,
                                                            ),
                                                        border: Border.all(
                                                          color: _border,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "${_bestOwner!.totalReservations} rezervacija",
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: _greenDark,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Center(
                                                      child: SizedBox(
                                                        width: 220,
                                                        child: _MiniInfoCard(
                                                          title: "Godina",
                                                          value: _bestOwner!
                                                              .year
                                                              .toString(),
                                                          icon: Icons
                                                              .event_rounded,
                                                          accent: _greenDark,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    flex: 4,
                                    child: _SectionCard(
                                      title: "Sažetak",
                                      subtitle: "Brzi pregled rezultata",
                                      border: _border,
                                      headerColor: _greenSoft2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: _bestOwner == null
                                            ? const Center(
                                                child: Text(
                                                  "Nema podataka.",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              )
                                            : Column(
                                                children: [
                                                  _InfoTile(
                                                    icon: Icons.person_rounded,
                                                    title: "Ime vlasnika",
                                                    value:
                                                        _bestOwner!.ownerName,
                                                    accent: _greenDark,
                                                    soft: _greenSoft2,
                                                    border: _border,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _InfoTile(
                                                    icon:
                                                        Icons.home_work_rounded,
                                                    title: "Ukupno rezervacija",
                                                    value: _bestOwner!
                                                        .totalReservations
                                                        .toString(),
                                                    accent: _greenDark,
                                                    soft: _greenSoft2,
                                                    border: _border,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _InfoTile(
                                                    icon: Icons
                                                        .calendar_today_rounded,
                                                    title: "Godina izvještaja",
                                                    value: _bestOwner!.year
                                                        .toString(),
                                                    accent: _greenDark,
                                                    soft: _greenSoft2,
                                                    border: _border,
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: _greenSoft2,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      border: Border.all(
                                                        color: _border,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
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

class _TopSwitchBar extends StatelessWidget {
  final _ReportTab selectedTab;
  final ValueChanged<_ReportTab> onChanged;

  const _TopSwitchBar({required this.selectedTab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDFE6DA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SwitchButton(
              title: "Ukupni prihod",
              icon: Icons.bar_chart_rounded,
              active: selectedTab == _ReportTab.income,
              activeColor: _ReportScreenState._green,
              onTap: () => onChanged(_ReportTab.income),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SwitchButton(
              title: "Najbolji vlasnik",
              icon: Icons.workspace_premium_rounded,
              active: selectedTab == _ReportTab.bestOwner,
              activeColor: _ReportScreenState._greenDark,
              onTap: () => onChanged(_ReportTab.bestOwner),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _SwitchButton({
    required this.title,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: active ? activeColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? activeColor.withOpacity(0.24) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? activeColor : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: active ? activeColor : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BestOwnerTab extends StatelessWidget {
  final Color border;
  final Color accent;
  final Color accentSoft;
  final Color text;
  final Color muted;
  final int? selectedYear;
  final BestOwnerByYear? bestOwner;

  const _BestOwnerTab({
    required this.border,
    required this.accent,
    required this.accentSoft,
    required this.text,
    required this.muted,
    required this.selectedYear,
    required this.bestOwner,
  });

  @override
  Widget build(BuildContext context) {
    if (bestOwner == null) {
      return _SectionCard(
        title: "Najbolji owner",
        subtitle: "Pregled za odabranu godinu",
        border: border,
        headerColor: accentSoft,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: accentSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Text(
              "Za godinu ${selectedYear ?? '-'} nema podataka.",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: text,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 6,
          child: _SectionCard(
            title: "Šampion godine",
            subtitle: "Owner sa najviše rezervacija",
            border: border,
            headerColor: accentSoft,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF7FCF4), Color(0xFFEAF6E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(26),
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: accent.withOpacity(0.28)),
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: accent,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Najbolji owner za ${bestOwner!.year}. godinu",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: muted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      bestOwner!.ownerName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: text,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: border),
                      ),
                      child: Text(
                        "${bestOwner!.totalReservations} rezervacija",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: accent,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: SizedBox(
                        width: 220,
                        child: _MiniInfoCard(
                          title: "Godina",
                          value: bestOwner!.year.toString(),
                          icon: Icons.event_rounded,
                          accent: accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 4,
          child: _SectionCard(
            title: "Sažetak",
            subtitle: "Brzi pregled rezultata",
            border: border,
            headerColor: accentSoft,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.person_rounded,
                    title: "Ime ownera",
                    value: bestOwner!.ownerName,
                    accent: accent,
                    soft: accentSoft,
                    border: border,
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.home_work_rounded,
                    title: "Ukupno rezervacija",
                    value: bestOwner!.totalReservations.toString(),
                    accent: accent,
                    soft: accentSoft,
                    border: border,
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.calendar_today_rounded,
                    title: "Godina izvještaja",
                    value: bestOwner!.year.toString(),
                    accent: accent,
                    soft: accentSoft,
                    border: border,
                  ),
                  const Spacer()
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const _MiniInfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDFE6DA)),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F2A1F),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accent;
  final Color soft;
  final Color border;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
    required this.soft,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2A1F),
                    fontSize: 15,
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

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color accentSoft;
  final Color border;
  final Color text;
  final Color muted;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.accentSoft,
    required this.border,
    required this.text,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: text,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: accent,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: muted,
                    fontSize: 12.5,
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

class _FilterCard extends StatelessWidget {
  final Widget child;
  final Color border;

  const _FilterCard({required this.child, required this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: child,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Color border;
  final Color headerColor;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.border,
    required this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F2A1F),
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;

  const _LineChart({required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(data: data),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels
              .map(
                (e) => Text(
                  e,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;

  _LineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const paddingLeft = 8.0;
    const paddingRight = 8.0;
    const paddingTop = 10.0;
    const paddingBottom = 28.0;

    final chartW = size.width - paddingLeft - paddingRight;
    final chartH = size.height - paddingTop - paddingBottom;

    final minV = data.reduce(math.min);
    final maxV = data.reduce(math.max);
    final range = (maxV - minV).abs() < 0.001 ? 1.0 : (maxV - minV);

    final gridPaint = Paint()
      ..color = const Color(0xFFDFE6DA)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = paddingTop + (chartH / 3) * i;
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - paddingRight, y),
        gridPaint,
      );
    }

    final linePaint = Paint()
      ..color = const Color(0xFF5F9F3B)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? paddingLeft + chartW / 2
          : paddingLeft + (chartW / (data.length - 1)) * i;
      final norm = (data[i] - minV) / range;
      final y = paddingTop + chartH * (1 - norm);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = const Color(0xFF1F2A1F);
    for (int i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? paddingLeft + chartW / 2
          : paddingLeft + (chartW / (data.length - 1)) * i;
      final norm = (data[i] - minV) / range;
      final y = paddingTop + chartH * (1 - norm);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.data != data;
}

class _PieChart extends StatelessWidget {
  final List<double> values;

  const _PieChart({required this.values});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PiePainter(values),
      child: const SizedBox.expand(),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<double> values;

  _PiePainter(this.values);

  final List<Color> palette = const [
    Color(0xFF5F9F3B),
    Color(0xFF2F7A35),
    Color(0xFF88C057),
    Color(0xFFB7E1A1),
    Color(0xFF1F2A1F),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (a, b) => a + b);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.2;

    final bgPaint = Paint()
      ..color = const Color(0xFFEAF6E5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    if (total <= 0) return;

    double start = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * (2 * math.pi);
      final paint = Paint()
        ..color = palette[i % palette.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        paint,
      );

      start += sweep;
    }

    final holePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.58, holePaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFDFE6DA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, radius, borderPaint);
    canvas.drawCircle(center, radius * 0.58, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) =>
      oldDelegate.values != values;
}

class _LegendItem {
  final String name;
  final double value;

  _LegendItem(this.name, this.value);
}

class _LegendList extends StatefulWidget {
  final List<_LegendItem> items;
  final double total;

  const _LegendList({required this.items, required this.total});

  @override
  State<_LegendList> createState() => _LegendListState();
}

class _LegendListState extends State<_LegendList> {
  final ScrollController _c = ScrollController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Color _dotColor(int i) {
    const palette = [
      Color(0xFF5F9F3B),
      Color(0xFF2F7A35),
      Color(0xFF88C057),
      Color(0xFFB7E1A1),
      Color(0xFF1F2A1F),
    ];
    return palette[i % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final total = widget.total;

    if (items.isEmpty) {
      return const Text(
        "Nema podataka",
        style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF6B7280)),
      );
    }

    return Scrollbar(
      controller: _c,
      thumbVisibility: true,
      child: ListView.builder(
        controller: _c,
        itemCount: items.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, i) {
          final it = items[i];
          final pct = total == 0 ? 0 : (it.value / total) * 100;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _dotColor(i),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    it.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2A1F),
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${pct.toStringAsFixed(0)}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6B7280),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
