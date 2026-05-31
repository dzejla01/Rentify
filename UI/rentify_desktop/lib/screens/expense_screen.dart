import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/helper/snackBar_helper.dart';
import 'package:rentify_desktop/models/expense.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/providers/expense_provider.dart';
import 'package:rentify_desktop/providers/property_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/utils/session.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  static const Color _green = Color(0xFF5F9F3B);
  static const Color _greenSoft = Color(0xFFEAF6E5);
  static const Color _border = Color(0xFFDFE6DA);
  static const Color _text = Color(0xFF1F2A1F);
  static const Color _muted = Color(0xFF6B7280);

  static const List<String> _categories = [
    'Održavanje',
    'Popravak',
    'Komunalije',
    'Osiguranje',
    'Porez',
    'Ostalo',
  ];

  late ExpenseProvider _expenseProvider;
  late PropertyProvider _propertyProvider;

  List<Expense> _expenses = [];
  List<Property> _properties = [];
  bool _loading = true;
  String? _filterCategory;

  @override
  void initState() {
    super.initState();
    _expenseProvider = context.read<ExpenseProvider>();
    _propertyProvider = context.read<PropertyProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final filter = <String, dynamic>{
        'UserId': Session.userId,
        'IncludeProperty': true,
        'Page': 0,
        'PageSize': 100,
        'IncludeTotalCount': false,
        if (_filterCategory != null) 'Category': _filterCategory,
      };

      final result = await _expenseProvider.get(filter: filter);

      final propResult = await _propertyProvider.get(
        filter: {
          'UserId': Session.userId,
          'IsActiveOnApp': true,
          'Page': 0,
          'PageSize': 100,
          'IncludeTotalCount': false,
        },
      );

      if (!mounted) return;
      setState(() {
        _expenses = result.items;
        _properties = propResult.items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      SnackbarHelper.showError(context, e.toString());
    }
  }

  Future<void> _openUpsertDialog({Expense? existing}) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ExpenseDialog(
        existing: existing,
        properties: _properties,
        onSave: (data) async {
          if (existing == null) {
            await _expenseProvider.insert(data);
          } else {
            await _expenseProvider.update(existing.id, data);
          }
        },
      ),
    );

    if (saved == true) await _load();
  }

  Future<void> _delete(Expense e) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Brisanje troška',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Da li ste sigurni da želite obrisati trošak "${e.description}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _expenseProvider.delete(e.id);
        await _load();
      } catch (err) {
        if (!mounted) return;
        SnackbarHelper.showError(context, err.toString());
      }
    }
  }

  double get _totalAmount =>
      _expenses.fold(0, (sum, e) => sum + e.amount);

  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: 'Troškovi',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SummaryCard(
                  label: 'Ukupno troškova',
                  value: '${_totalAmount.toStringAsFixed(2)} KM',
                  icon: Icons.receipt_long_rounded,
                  color: _green,
                  soft: _greenSoft,
                  border: _border,
                ),
                const SizedBox(width: 14),
                _SummaryCard(
                  label: 'Broj zapisa',
                  value: _expenses.length.toString(),
                  icon: Icons.list_alt_rounded,
                  color: _green,
                  soft: _greenSoft,
                  border: _border,
                ),
                const Spacer(),
                _categoryFilter(),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _openUpsertDialog(),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'Novi trošak',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
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
            const SizedBox(height: 16),
            Expanded(child: _table()),
          ],
        ),
      ),
    );
  }

  Widget _categoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _filterCategory,
          hint: const Text(
            'Sve kategorije',
            style: TextStyle(fontWeight: FontWeight.w700, color: _muted),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'Sve kategorije',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            ..._categories.map(
              (c) => DropdownMenuItem<String?>(
                value: c,
                child: Text(
                  c,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
          onChanged: (v) {
            setState(() => _filterCategory = v);
            _load();
          },
        ),
      ),
    );
  }

  Widget _table() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, size: 56, color: _border),
            const SizedBox(height: 12),
            Text(
              _filterCategory != null
                  ? 'Nema troškova za kategoriju "$_filterCategory".'
                  : 'Nema evidentiranih troškova.',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: _muted,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
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
          _tableHeader(),
          const Divider(height: 1, color: _border),
          Expanded(
            child: ListView.separated(
              itemCount: _expenses.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: _border),
              itemBuilder: (_, i) => _tableRow(_expenses[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    const style = TextStyle(
      fontWeight: FontWeight.w900,
      color: _muted,
      fontSize: 12.5,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FBF6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('OPIS', style: style)),
          Expanded(flex: 2, child: Text('NEKRETNINA', style: style)),
          Expanded(flex: 1, child: Text('KATEGORIJA', style: style)),
          Expanded(flex: 1, child: Text('DATUM', style: style)),
          SizedBox(
            width: 100,
            child: Text('IZNOS', style: style, textAlign: TextAlign.right),
          ),
          SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _tableRow(Expense e) {
    final dateStr = DateFormat('dd.MM.yyyy').format(e.date.toLocal());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              e.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: _text,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              e.property?.name ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _muted,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: _CategoryChip(category: e.category),
          ),
          Expanded(
            flex: 1,
            child: Text(
              dateStr,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _muted,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              '${e.amount.toStringAsFixed(2)} KM',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: _green,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  color: _green,
                  tooltip: 'Uredi',
                  onPressed: () => _openUpsertDialog(existing: e),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, size: 18),
                  color: Colors.red,
                  tooltip: 'Obriši',
                  onPressed: () => _delete(e),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.soft,
    required this.border,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color soft;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                  fontSize: 12.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: color,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});
  final String category;

  Color get _color {
    switch (category) {
      case 'Održavanje':
        return const Color(0xFF1565C0);
      case 'Popravak':
        return const Color(0xFFE65100);
      case 'Komunalije':
        return const Color(0xFF2E7D32);
      case 'Osiguranje':
        return const Color(0xFF6A1B9A);
      case 'Porez':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF546E7A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withAlpha(25),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _color.withAlpha(60)),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ExpenseDialog extends StatefulWidget {
  const _ExpenseDialog({
    required this.existing,
    required this.properties,
    required this.onSave,
  });

  final Expense? existing;
  final List<Property> properties;
  final Future<void> Function(Map<String, dynamic>) onSave;

  @override
  State<_ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<_ExpenseDialog> {
  static const Color _green = Color(0xFF5F9F3B);
  static const Color _border = Color(0xFFDFE6DA);

  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  String _category = _ExpenseScreenState._categories.first;
  DateTime _date = DateTime.now();
  int? _propertyId;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _descCtrl.text = e.description;
      _amountCtrl.text = e.amount.toStringAsFixed(2);
      _category = e.category;
      _date = e.date.toLocal();
      _propertyId = e.propertyId;
    }
    _dateCtrl.text = DateFormat('dd.MM.yyyy').format(_date);
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
      _dateCtrl.text = DateFormat('dd.MM.yyyy').format(picked);
    }
  }

  Future<void> _submit() async {
    final desc = _descCtrl.text.trim();
    final amountStr = _amountCtrl.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(amountStr);

    if (desc.isEmpty) {
      setState(() => _error = 'Opis je obavezan.');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Unesite ispravan iznos veći od 0.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.onSave({
        'userId': Session.userId,
        'propertyId': _propertyId,
        'description': desc,
        'amount': amount,
        'date': _date.toUtc().toIso8601String(),
        'category': _category,
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  InputDecoration _dec(String hint, {IconData? icon}) => InputDecoration(
    hintText: hint,
    prefixIcon: icon != null ? Icon(icon, size: 18, color: _green) : null,
    isDense: true,
    filled: true,
    fillColor: const Color(0xFFF8FBF6),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _green, width: 1.6),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF6E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: _green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Uredi trošak' : 'Novi trošak',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descCtrl,
                decoration: _dec('Opis troška', icon: Icons.notes_rounded),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _dec(
                        'Iznos (KM)',
                        icon: Icons.payments_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _dateCtrl,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: _dec(
                        'Datum',
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category,
                      isExpanded: true,
                      decoration: _dec(
                        'Kategorija',
                        icon: Icons.category_rounded,
                      ),
                      items: _ExpenseScreenState._categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _category = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      value: _propertyId,
                      isExpanded: true,
                      decoration: _dec(
                        'Nekretnina',
                        icon: Icons.home_rounded,
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'Bez nekretnine',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        ...widget.properties.map(
                          (p) => DropdownMenuItem<int?>(
                            value: p.id,
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _propertyId = v),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _saving ? null : () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: _border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Odustani',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEdit ? 'Spremi promjene' : 'Dodaj trošak',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
