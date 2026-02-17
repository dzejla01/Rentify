import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/helper/date_helper.dart';
import 'package:rentify_desktop/helper/snackBar_helper.dart';
import 'package:rentify_desktop/helper/text_editing_controller_helper.dart';
import 'package:rentify_desktop/models/payment.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/reservation.dart';
import 'package:rentify_desktop/models/user.dart';
import 'package:rentify_desktop/providers/payment_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/validation/validation_model/validation_field_rule.dart';
import 'package:rentify_desktop/validation/validation_model/validation_rules.dart';
import 'package:rentify_desktop/validation/validation_use/universal_error_removal.dart';
import 'package:rentify_desktop/validation/validation_use/universal_validator.dart';

class PaymentAddingScreen extends StatefulWidget {
  final User user;
  final Property property;
  final int billMonth;
  final int billYear;
  final bool isMonthly; 
  final Payment? previousPayment; 
  final Reservation? reservation; 

  const PaymentAddingScreen({
    super.key,
    required this.user,
    required this.property,
    required this.billMonth,
    required this.billYear,
    required this.isMonthly,
    this.previousPayment,
    this.reservation,
  });

  @override
  State<PaymentAddingScreen> createState() => _PaymentAddingScreenState();
}

class _PaymentAddingScreenState extends State<PaymentAddingScreen> {
  late PaymentProvider _paymentProvider;

  final _fields = Fields.fromNames(["title", "amount", "comment"]);
  final _dateToPayCtrl = TextEditingController();
  final _warningDateCtrl = TextEditingController();

  DateTime? _dateToPay;
  DateTime? _warningDateToPay;

  DateTime? _suggestedDateToPay;
  DateTime? _suggestedWarningDateToPay;

  Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    _initFixedFields();
    _hookErrorAutoRemoval();
  }

  void _initFixedFields() {
    // ✅ Naziv (fiksan)
    if (widget.isMonthly) {
      final m = widget.billMonth.toString().padLeft(2, '0');
      final y = widget.billYear;
      _fields.controller("title").text = "Zahtjev za uplatu mjesečne rate ($m.$y)";
    } else {
      _fields.controller("title").text = "Zahtjev za uplatu kratkog boravka";
    }

    // ✅ Iznos (fiksan)
    if (widget.isMonthly) {
      final price = widget.property.pricePerMonth ?? 0;
      _fields.controller("amount").text = price.toStringAsFixed(2);
    } else {
      // short stay: pricePerDay * brojDana
      final perDay = widget.property.pricePerDay ?? 0;

      final start = widget.reservation?.startDateOfRenting;
      final end = widget.reservation?.endDateOfRenting;

      int days = 1;
      if (start != null && end != null) {
        days = end.difference(start).inDays;
        if (days < 1) days = 1;
      }

      final total = perDay * days;
      _fields.controller("amount").text = total.toStringAsFixed(2);
    }

    // ✅ Suggestions samo za monthly (na osnovu previousPayment)
    if (widget.isMonthly && widget.previousPayment != null) {
      final prev = widget.previousPayment!;

      if (prev.dateToPay != null) {
        final day = prev.dateToPay!.day;
        _suggestedDateToPay = DateHelper.safeDayInMonth(
          widget.billYear,
          widget.billMonth,
          day,
        );
      }

      if (prev.warningDateToPay != null) {
        final wDay = prev.warningDateToPay!.day;
        _suggestedWarningDateToPay = DateHelper.safeDayInMonth(
          widget.billYear,
          widget.billMonth,
          wDay,
        );
      }
    }
  }

  void _hookErrorAutoRemoval() {
    _fields.map.forEach((name, ctrl) {
      ErrorAutoRemoval.removeErrorOnTextField(
        field: name,
        fieldErrors: _errors,
        controller: ctrl,
        setState: () => setState(() {}),
      );
    });

    ErrorAutoRemoval.removeErrorOnTextField(
      field: "dateToPay",
      fieldErrors: _errors,
      controller: _dateToPayCtrl,
      setState: () => setState(() {}),
    );

    ErrorAutoRemoval.removeErrorOnTextField(
      field: "warningDateToPay",
      fieldErrors: _errors,
      controller: _warningDateCtrl,
      setState: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    _fields.dispose();
    _dateToPayCtrl.dispose();
    _warningDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime? initial,
    required void Function(DateTime picked) onPicked,
  }) async {
    // monthly: ograniči na taj mjesec
    // short stay: dozvoli širi opseg
    late DateTime first;
    late DateTime last;

    if (widget.isMonthly) {
      first = DateTime(widget.billYear, widget.billMonth, 1);
      last = DateTime(widget.billYear, widget.billMonth + 1, 0);
    } else {
      final now = DateTime.now();
      first = DateTime(now.year, now.month, now.day);
      last = now.add(const Duration(days: 365));
    }

    final init = initial ?? first;

    final picked = await showDatePicker(
      context: context,
      initialDate: init.isBefore(first)
          ? first
          : (init.isAfter(last) ? last : init),
      firstDate: first,
      lastDate: last,
    );

    if (picked == null) return;
    onPicked(picked);
  }

  Future<void> _submit() async {
    final rules = <FieldRule>[
      Rules.requiredText("title", _fields.text("title"), "Naziv je obavezan."),
      Rules.minLength("title", _fields.text("title"), 3, "Naziv mora imati barem 3 karaktera."),
      Rules.positiveNumber("amount", _fields.text("amount"), "Iznos mora biti pozitivan broj."),
      Rules.requiredText("comment", _fields.text("comment"), "Komentar je obavezan."),
      FieldRule(
        "dateToPay",
        () => _dateToPay == null ? "Datum do kad se treba platiti je obavezan." : null,
      ),
      FieldRule(
        "warningDateToPay",
        () => _warningDateToPay == null ? "Warning datum je obavezan." : null,
      ),
    ];

    final isValid = ValidationEngine.validate(rules, (field, message) {
      _errors[field] = message;
      setState(() {});
    });

    if (!isValid) return;

    try {
      final price = double.tryParse(_fields.text("amount").replaceAll(",", ".")) ?? 0.0;

      final request = <String, dynamic>{
        "userId": widget.user.id,
        "propertyId": widget.property.id,
        "price": price,
        "isPayed": false,
        "name": _fields.text("title"),
        "comment": _fields.text("comment"),
        "monthNumber": widget.isMonthly ? widget.billMonth : 0,
        "yearNumber": widget.isMonthly ? widget.billYear : 0,
        "dateToPay": DateHelper.toUtcIsoNullable(_dateToPay),
        "warningDateToPay": DateHelper.toUtcIsoNullable(_warningDateToPay),
      };

      await _paymentProvider.insert(request);

      SnackbarHelper.showSuccess(context, "Zahtjev uspješno poslan.");
      Navigator.pop(context, true);
    } catch (e) {
      SnackbarHelper.showError(context, "Greška prilikom slanja zahtjeva.");
    }
  }

  InputDecoration _decoration(String key) => InputDecoration(
        border: const OutlineInputBorder(),
        errorText: _errors[key],
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      );

  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: "Novo plaćanje: ${widget.user.firstName} ${widget.user.lastName}",
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nekretnina: ${widget.property.name}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              const Text("Naziv:*"),
              const SizedBox(height: 5),
              TextField(
                enabled: false, // ✅ fiksno
                controller: _fields.controller("title"),
                decoration: _decoration("title"),
              ),

              const SizedBox(height: 20),

              const Text("Iznos:*"),
              const SizedBox(height: 5),
              TextField(
                enabled: false, // ✅ fiksno (anti-zloupotreba)
                controller: _fields.controller("amount"),
                keyboardType: TextInputType.number,
                decoration: _decoration("amount"),
              ),

              const SizedBox(height: 20),

              const Text("Datum do kad se treba platiti:*"),
              const SizedBox(height: 5),
              TextField(
                controller: _dateToPayCtrl,
                readOnly: true,
                onTap: () => _pickDate(
                  initial: _dateToPay,
                  onPicked: (d) {
                    setState(() {
                      _dateToPay = d;
                      _dateToPayCtrl.text = DateHelper.format(d);
                      _errors.remove("dateToPay");

                      // ako warning ode iza roka, očisti ga
                      if (_warningDateToPay != null && _warningDateToPay!.isAfter(d)) {
                        _warningDateToPay = null;
                        _warningDateCtrl.clear();
                      }
                    });
                  },
                ),
                decoration: _decoration("dateToPay").copyWith(
                  hintText: (widget.isMonthly && _suggestedDateToPay != null)
                      ? "Predloženo: ${DateHelper.format(_suggestedDateToPay!)}"
                      : "Odaberite datum",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: () => _pickDate(
                      initial: _dateToPay,
                      onPicked: (d) {
                        setState(() {
                          _dateToPay = d;
                          _dateToPayCtrl.text = DateHelper.format(d);
                          _errors.remove("dateToPay");

                          if (_warningDateToPay != null && _warningDateToPay!.isAfter(d)) {
                            _warningDateToPay = null;
                            _warningDateCtrl.clear();
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text("Warning datum (kada počinju upozorenja):*"),
              const SizedBox(height: 5),
              TextField(
                controller: _warningDateCtrl,
                readOnly: true,
                onTap: () => _pickDate(
                  initial: _warningDateToPay ?? _dateToPay,
                  onPicked: (d) {
                    setState(() {
                      _warningDateToPay = d;
                      _warningDateCtrl.text = DateHelper.format(d);
                      _errors.remove("warningDateToPay");
                    });
                  },
                ),
                decoration: _decoration("warningDateToPay").copyWith(
                  hintText: (widget.isMonthly && _suggestedWarningDateToPay != null)
                      ? "Predloženo: ${DateHelper.format(_suggestedWarningDateToPay!)}"
                      : "Odaberite datum",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.notification_important_outlined),
                    onPressed: () => _pickDate(
                      initial: _warningDateToPay ?? _dateToPay,
                      onPicked: (d) {
                        setState(() {
                          _warningDateToPay = d;
                          _warningDateCtrl.text = DateHelper.format(d);
                          _errors.remove("warningDateToPay");
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text("Komentar:*"),
              const SizedBox(height: 5),
              TextField(
                controller: _fields.controller("comment"),
                maxLines: 5,
                decoration: _decoration("comment")
                    .copyWith(contentPadding: const EdgeInsets.all(10)),
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Pošalji zahtjev"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
