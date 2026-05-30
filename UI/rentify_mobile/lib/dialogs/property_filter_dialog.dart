import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/dialogs/base_dialogs.dart';
import 'package:rentify_mobile/helper/text_editing_controller_helper.dart'; // Fields
import 'package:rentify_mobile/models/city.dart';
import 'package:rentify_mobile/providers/city_provider.dart';
import 'package:rentify_mobile/validation/validation_model/validation_field_rule.dart';
import 'package:rentify_mobile/validation/validation_model/validation_rules.dart';
import 'package:rentify_mobile/validation/validation_use/universal_error_removal.dart';
import 'package:rentify_mobile/validation/validation_use/universal_validator.dart';

class PropertyFilterDialog extends StatefulWidget {
  const PropertyFilterDialog({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  State<PropertyFilterDialog> createState() => PropertyFilterDialogState();
}

class PropertyFilterDialogState extends State<PropertyFilterDialog> {
  late final Fields _fields;

  final Map<String, String?> _errors = {};
  List<City> _cities = [];
  int? _selectedCityId;
  bool _citiesLoading = false;

  @override
  void initState() {
    super.initState();

    _fields = Fields.fromNames(const [
      "MinPrice",
      "MaxPrice",
      "MinDailyPrice",
      "MaxDailyPrice",
    ]);

    for (final name in _fields.map.keys) {
      ErrorAutoRemoval.removeErrorOnTextField(
        field: name,
        fieldErrors: _errors,
        controller: _fields.controller(name),
        setState: () => setState(() {}),
      );
    }

    _loadCities();
  }

  Future<void> _loadCities() async {
    setState(() => _citiesLoading = true);

    try {
      final result = await context.read<CityProvider>().get(
        filter: {"retrieveAll": true, "page": 0, "pageSize": 1000},
      );
      if (!mounted) return;
      setState(() => _cities = result.items);
    } finally {
      if (mounted) setState(() => _citiesLoading = false);
    }
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  double? _tryParseDouble(String s) {
    final v = s.trim();
    if (v.isEmpty) return null;
    return double.tryParse(v.replaceAll(",", "."));
  }

  bool _validate() {
    final minMonthlyTxt = _fields.text("MinPrice").trim();
    final maxMonthlyTxt = _fields.text("MaxPrice").trim();

    final minDailyTxt = _fields.text("MinDailyPrice").trim();
    final maxDailyTxt = _fields.text("MaxDailyPrice").trim();

    final rules = <FieldRule>[
      if (minMonthlyTxt.isNotEmpty)
        Rules.positiveNumber(
          "MinPrice",
          minMonthlyTxt,
          "Min mjesečna cijena mora biti broj > 0",
        ),
      if (maxMonthlyTxt.isNotEmpty)
        Rules.positiveNumber(
          "MaxPrice",
          maxMonthlyTxt,
          "Max mjesečna cijena mora biti broj > 0",
        ),

      FieldRule("MonthlyMinMax", () {
        final minV = _tryParseDouble(minMonthlyTxt);
        final maxV = _tryParseDouble(maxMonthlyTxt);
        if (minV == null || maxV == null) return null;
        if (minV > maxV) return "Min mjesečna cijena ne može biti veća od Max mjesečne";
        return null;
      }),

      if (minDailyTxt.isNotEmpty)
        Rules.positiveNumber(
          "MinDailyPrice",
          minDailyTxt,
          "Min dnevna cijena mora biti broj > 0",
        ),
      if (maxDailyTxt.isNotEmpty)
        Rules.positiveNumber(
          "MaxDailyPrice",
          maxDailyTxt,
          "Max dnevna cijena mora biti broj > 0",
        ),

      // Daily range (Min <= Max)
      FieldRule("DailyMinMax", () {
        final minV = _tryParseDouble(minDailyTxt);
        final maxV = _tryParseDouble(maxDailyTxt);
        if (minV == null || maxV == null) return null;
        if (minV > maxV) return "Min dnevna cijena ne može biti veća od Max dnevne";
        return null;
      }),
    ];

    _errors.clear();

    final ok = ValidationEngine.validate(rules, (field, message) {
      // mapiramo range greške na "Max" polje (da korisnik vidi gdje je problem)
      if (field == "MonthlyMinMax") {
        _errors["MaxPrice"] = message;
      } else if (field == "DailyMinMax") {
        _errors["MaxDailyPrice"] = message;
      } else {
        _errors[field] = message;
      }
    });

    setState(() {});
    return ok;
  }

  void _onReset() {
    _selectedCityId = null;
    _fields.setText("MinPrice", "");
    _fields.setText("MaxPrice", "");
    _fields.setText("MinDailyPrice", "");
    _fields.setText("MaxDailyPrice", "");

    _errors.clear();
    setState(() {});
    Navigator.pop(context, <String, dynamic>{});
  }

  void _onApply() {
    if (!_validate()) return;

    final data = <String, dynamic>{};

    final minMonthly = _tryParseDouble(_fields.text("MinPrice"));
    final maxMonthly = _tryParseDouble(_fields.text("MaxPrice"));

    final minDaily = _tryParseDouble(_fields.text("MinDailyPrice"));
    final maxDaily = _tryParseDouble(_fields.text("MaxDailyPrice"));

    if (_selectedCityId != null) data["CityId"] = _selectedCityId;

    if (minMonthly != null) data["MinPrice"] = minMonthly;
    if (maxMonthly != null) data["MaxPrice"] = maxMonthly;

    if (minDaily != null) data["MinDailyPrice"] = minDaily;
    if (maxDaily != null) data["MaxDailyPrice"] = maxDaily;

    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return RentifyBaseDialog(
      title: "Filteri nekretnina",
      onClose: widget.onClose,
      width: 360,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: _cities.any((x) => x.id == _selectedCityId)
                  ? _selectedCityId
                  : null,
              items: _cities
                  .map(
                    (city) => DropdownMenuItem<int>(
                      value: city.id,
                      child: Text(city.name),
                    ),
                  )
                  .toList(),
              onChanged: _citiesLoading
                  ? null
                  : (value) => setState(() => _selectedCityId = value),
              decoration: InputDecoration(
                hintText: _citiesLoading ? "Ucitavam gradove..." : "Grad",
                prefixIcon: const Icon(Icons.location_city_rounded),
                filled: true,
                fillColor: const Color(0xFFF6F7F8),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
        
            _field(
              ctrl: _fields.controller("MinPrice"),
              hint: "Min mjesečna cijena",
              icon: Icons.south_west_rounded,
              keyboardType: TextInputType.number,
              errorText: _errors["MinPrice"],
            ),
            const SizedBox(height: 10),
        
            _field(
              ctrl: _fields.controller("MaxPrice"),
              hint: "Max mjesečna cijena",
              icon: Icons.north_east_rounded,
              keyboardType: TextInputType.number,
              errorText: _errors["MaxPrice"],
            ),
        
            const SizedBox(height: 16),
        
            _field(
              ctrl: _fields.controller("MinDailyPrice"),
              hint: "Min dnevna cijena",
              icon: Icons.south_west_rounded,
              keyboardType: TextInputType.number,
              errorText: _errors["MinDailyPrice"],
            ),
            const SizedBox(height: 10),
        
            _field(
              ctrl: _fields.controller("MaxDailyPrice"),
              hint: "Max dnevna cijena",
              icon: Icons.north_east_rounded,
              keyboardType: TextInputType.number,
              errorText: _errors["MaxDailyPrice"],
            ),
        
            const SizedBox(height: 16),
        
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _onReset,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Reset"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5F9F3B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text("Primijeni"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        errorText: errorText,
        filled: true,
        fillColor: const Color(0xFFF6F7F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
