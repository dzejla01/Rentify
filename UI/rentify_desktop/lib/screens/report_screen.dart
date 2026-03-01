import 'dart:io';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rentify_desktop/models/monthly_income.dart';
import 'package:rentify_desktop/models/property_income.dart';
import 'package:rentify_desktop/providers/report_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/utils/session.dart';

import 'package:rentify_desktop/models/income_report.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // 🎨 Rentify theme
  static const Color _green = Color(0xFF5F9F3B);
  static const Color _greenSoft = Color(0xFFEAF6E5);
  static const Color _border = Color(0xFFDFE6DA);
  static const Color _text = Color(0xFF1F2A1F);
  static const Color _muted = Color(0xFF6B7280);

  final _api = IncomeReportApi();

  bool _loading = false;

  // ✅ real data from API
  List<MonthlyIncome> _monthly = [];
  List<PropertyIncome> _byProperty = [];

  MonthlyIncome? _selectedMonth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  Future<List<int>> _buildReportPdfBytes({
    required List<MonthlyIncome> monthly,
    required List<PropertyIncome> byProperty,
    required MonthlyIncome selected,
    required double totalSelected,
  }) async {
    final doc = pw.Document();

    final now = DateTime.now();
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');

    String km(num v) => "${v.toStringAsFixed(0)} KM";

    // sortiranja (da u pdf bude stabilno)
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
          // HEADER
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
                  "Mjesec: ${selected.label}",
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 16),

          // KPI
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

          // TREND TABLE
          pw.Text(
            "Trend prihoda (zadnji mjeseci)",
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
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
            },
            headers: const ["Mjesec", "Ukupno"],
            data: monthlySorted.map((m) => [m.label, km(m.total)]).toList(),
          ),

          pw.SizedBox(height: 18),

          // BY PROPERTY TABLE
          pw.Text(
            "Prihod po nekretnini (${selected.label})",
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

  Future<void> _loadInitial() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final ownerId = Session.userId!;
      final report = await _api.getIncomeReport(
        ownerId: ownerId,
        monthsBack: 6,
      );

      // sort just in case (year/month)
      final sorted = [...report.monthly]
        ..sort((a, b) {
          final ay = a.year * 100 + a.month;
          final by = b.year * 100 + b.month;
          return ay.compareTo(by);
        });

      final last = sorted.isNotEmpty ? sorted.last : null;

      setState(() {
        _monthly = sorted;
        _selectedMonth = last;
      });

      // load by property for selected month
      if (last != null) {
        await _loadByProperty(last);
      } else {
        setState(() => _byProperty = []);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Greška: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _printReport() async {
    if (_selectedMonth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nema podataka za printanje.")),
      );
      return;
    }

    // 1) Save As dialog
    final label = _selectedMonth!.label.replaceAll('.', '_'); // npr 12_2025
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Sačuvaj PDF izvještaj',
      fileName: 'Rentify_Izvjestaj_$label.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (path == null) return; // user cancel

    try {
      setState(() => _loading = true);

      // 2) napravi PDF bytes
      final bytes = await _buildReportPdfBytes(
        monthly: _monthly,
        byProperty: _byProperty,
        selected: _selectedMonth!,
        totalSelected: _selectedMonthTotal,
      );

      // 3) snimi
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      // 4) otvori PDF
      await OpenFilex.open(file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ne mogu napraviti PDF: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadByProperty(MonthlyIncome month) async {
    final ownerId = Session.userId!;
    final report = await _api.getIncomeReport(
      ownerId: ownerId,
      monthsBack: 6,
      year: month.year,
      month: month.month,
    );

    setState(() {
      _byProperty = report.byProperty;
    });
  }

  double get _selectedMonthTotal =>
      _byProperty.fold<double>(0, (a, b) => a + b.total);

  String _km(num v) => "${v.toStringAsFixed(0)} KM";

  @override
  Widget build(BuildContext context) {
    final selectedLabel = _selectedMonth?.label ?? "-";

    // RIGHT: map to entries for existing UI
    final propertyEntries =
        _byProperty.map((e) => MapEntry(e.propertyName, e.total)).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final lineData = _monthly.map((e) => e.total).toList();
    final lineLabels = _monthly.map((e) => e.label).toList();

    final kpiValue = (_monthly.isNotEmpty ? _monthly.last.total : 0.0);

    return RentifyBasePage(
      title: "Izvještaji",
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP: KPI + month selector
                Row(
                  children: [
                    Expanded(
                      child: _KpiCard(
                        title: "Ukupni mjesečni prihod",
                        value: _km(kpiValue),
                        subtitle: "Plaćeni payments • trend zadnjih mjeseci",
                        icon: Icons.payments_rounded,
                        green: _green,
                        greenSoft: _greenSoft,
                        border: _border,
                        text: _text,
                        muted: _muted,
                      ),
                    ),
                    const SizedBox(width: 14),

                    _FilterCard(
                      border: _border,
                      greenSoft: _greenSoft,
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
                            "Mjesec:",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _text,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 140,
                            child: DropdownButtonFormField<MonthlyIncome>(
                              value: _selectedMonth,
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
                                  borderSide: const BorderSide(color: _border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: _border),
                                ),
                              ),
                              items: _monthly
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(
                                        m.label,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) async {
                                if (v == null) return;
                                setState(() => _selectedMonth = v);
                                try {
                                  setState(() => _loading = true);
                                  await _loadByProperty(v);
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Greška: $e")),
                                  );
                                } finally {
                                  if (mounted) setState(() => _loading = false);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // ✅ PRINT BUTTON
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _printReport,
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: const Text(
                        "Printaj Izvještaj",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
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
                  child: Row(
                    children: [
                      // LEFT: line chart
                      Expanded(
                        flex: 6,
                        child: _SectionCard(
                          title: "Trend prihoda (mjeseci)",
                          subtitle: "Line chart • ukupni prihod po mjesecima",
                          border: _border,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                            child: _LineChart(
                              data: lineData,
                              labels: lineLabels,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // RIGHT: pie + list
                      Expanded(
                        flex: 5,
                        child: _SectionCard(
                          title: "Prihod po nekretnini",
                          subtitle: "Pie chart • raspodjela za $selectedLabel",
                          border: _border,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                            child: Column(
                              children: [
                                // total
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
                                  height: 160,
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
                                                (e) =>
                                                    _LegendItem(e.key, e.value),
                                              )
                                              .toList(),
                                          total: _selectedMonthTotal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),
                                const Divider(height: 1, color: _border),
                                const SizedBox(height: 10),

                                // list rows
                                Expanded(
                                  child: propertyEntries.isEmpty
                                      ? const Center(
                                          child: Text(
                                            "Nema podataka.",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          itemCount: propertyEntries.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 10),
                                          itemBuilder: (context, i) {
                                            final e = propertyEntries[i];
                                            final pct = _selectedMonthTotal == 0
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
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: _border,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.home_rounded,
                                                    size: 18,
                                                    color: _green,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      e.key,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: _text,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "${_km(e.value)} • ${pct.toStringAsFixed(0)}%",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
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
              ],
            ),
          ),

          // loading overlay
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

// =====================
// UI BUILDING BLOCKS
// =====================

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color green;
  final Color greenSoft;
  final Color border;
  final Color text;
  final Color muted;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.green,
    required this.greenSoft,
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
              color: greenSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Icon(icon, color: green, size: 22),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: green,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
  final Color greenSoft;

  const _FilterCard({
    required this.child,
    required this.border,
    required this.greenSoft,
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
      child: child,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Color border;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.border,
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
              color: const Color(0xFFEAF6E5),
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

// =====================
// LINE CHART (no deps)
// =====================

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

    // grid
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

    // line
    final linePaint = Paint()
      ..color = const Color(0xFF5F9F3B)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = paddingLeft + (chartW / (data.length - 1)) * i;
      final norm = (data[i] - minV) / range;
      final y = paddingTop + chartH * (1 - norm);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // points
    final dotPaint = Paint()..color = const Color(0xFF1F2A1F);
    for (int i = 0; i < data.length; i++) {
      final x = paddingLeft + (chartW / (data.length - 1)) * i;
      final norm = (data[i] - minV) / range;
      final y = paddingTop + chartH * (1 - norm);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.data != data;
}

// =====================
// PIE CHART (no deps)
// =====================

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
