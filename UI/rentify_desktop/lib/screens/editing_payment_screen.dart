import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/helper/date_helper.dart';
import 'package:rentify_desktop/helper/snackBar_helper.dart';
import 'package:rentify_desktop/helper/text_editing_controller_helper.dart';
import 'package:rentify_desktop/models/payment.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/user.dart';
import 'package:rentify_desktop/providers/payment_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/validation/validation_model/validation_field_rule.dart';
import 'package:rentify_desktop/validation/validation_model/validation_rules.dart';
import 'package:rentify_desktop/validation/validation_use/universal_error_removal.dart';
import 'package:rentify_desktop/validation/validation_use/universal_validator.dart';

class PaymentEditingScreen extends StatefulWidget {
  final User user;
  final Property? property;
  final Payment payment;
  final bool isMonthly;

  const PaymentEditingScreen({
    super.key,
    required this.user,
    required this.payment,
    required this.isMonthly,
    this.property,
  });

  @override
  State<PaymentEditingScreen> createState() => _PaymentEditingScreenState();
}

class _PaymentEditingScreenState extends State<PaymentEditingScreen> {
  late PaymentProvider _paymentProvider;

  final _fields = Fields.fromNames(["title", "amount", "comment"]);
  final _dateToPayCtrl = TextEditingController();
  final _warningDateCtrl = TextEditingController();

  DateTime? _dateToPay;
  DateTime? _warningDateToPay;

  Map<String, String?> _errors = {};

  bool get _isReadOnly =>
      widget.payment.isPayed == true; 

  @override
  void initState() {
    super.initState();
    _paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    _fillFromPayment(widget.payment);
    _attachAutoRemoval();
  }

  void _fillFromPayment(Payment p) {
    _fields.controller("title").text = p.name;
    _fields.controller("amount").text = p.price.toStringAsFixed(2);
    _fields.controller("comment").text = p.comment;

    _dateToPay = p.dateToPay;
    _warningDateToPay = p.warningDateToPay;

    _dateToPayCtrl.text = _dateToPay != null
        ? DateHelper.format(_dateToPay!)
        : "";
    _warningDateCtrl.text = _warningDateToPay != null
        ? DateHelper.format(_warningDateToPay!)
        : "";
  }

  void _attachAutoRemoval() {
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
    DateTime first;
    DateTime last;

    if (widget.isMonthly) {
      // ✅ najamnina: zaključaj na payment month/year
      final m = widget.payment.monthNumber;
      final y = widget.payment.yearNumber;

      first = DateTime(y, m, 1);
      last = DateTime(y, m + 1, 0);
    } else {
      // ✅ kratki boravak: bez ograničenja (široko)
      final now = DateTime.now();
      first = DateTime(now.year - 2, 1, 1);
      last = DateTime(now.year + 2, 12, 31);
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
    if (_isReadOnly) return;

    final rules = <FieldRule>[
      Rules.requiredText("title", _fields.text("title"), "Naziv je obavezan."),
      Rules.minLength(
        "title",
        _fields.text("title"),
        3,
        "Naziv mora imati barem 3 karaktera.",
      ),
      Rules.requiredText(
        "comment",
        _fields.text("comment"),
        "Komentar je obavezan.",
      ),
      FieldRule(
        "dateToPay",
        () => _dateToPay == null ? "Rok plaćanja je obavezan." : null,
      ),
      FieldRule(
        "warningDateToPay",
        () => _warningDateToPay == null ? "Warning datum je obavezan." : null,
      ),

      FieldRule(
        "dateToPay",
        () => _dateToPay == null
            ? "Rok plaćanja je obavezan."
            : null,
      ),
      FieldRule(
        "warningDateToPay",
        () => _warningDateToPay == null ? "Warning datum je obavezan." : null,
      ),
      FieldRule("dateToPay", () {
        if (_dateToPay == null || _warningDateToPay == null) return null;

        if (_dateToPay!.isAfter(_warningDateToPay!)) {
          return "Rok plaćanja ne može biti poslije warning datuma.";
        }
        return null;
      }),
      FieldRule("warningDateToPay", () {
        if (_dateToPay == null || _warningDateToPay == null) {
          return null;
        }

        final due = DateTime(
          _dateToPay!.year,
          _dateToPay!.month,
          _dateToPay!.day,
        );

        final warning = DateTime(
          _warningDateToPay!.year,
          _warningDateToPay!.month,
          _warningDateToPay!.day,
        );

        if (warning.isAtSameMomentAs(due)) {
          return "Warning datum ne smije biti isti kao rok plaćanja.";
        }

        return null;
      }),
      FieldRule("dateToPay", () {
        if (_dateToPay == null || _warningDateToPay == null) {
          return null;
        }

        final due = DateTime(
          _dateToPay!.year,
          _dateToPay!.month,
          _dateToPay!.day,
        );

        final warning = DateTime(
          _warningDateToPay!.year,
          _warningDateToPay!.month,
          _warningDateToPay!.day,
        );

        if (warning.isAtSameMomentAs(due)) {
          return "Rok plaćana ne smije biti isti kao warning datum.";
        }

        return null;
      }),
      
      if (!widget.isMonthly)
        Rules.positiveNumber(
          "amount",
          _fields.text("amount"),
          "Iznos mora biti pozitivan broj.",
        ),
    ];

    final isValid = ValidationEngine.validate(rules, (field, message) {
      _errors[field] = message;
      setState(() {});
    });
    if (!isValid) return;

    try {
      final req = <String, dynamic>{
        "userId": widget.payment.userId,
        "propertyId": widget.payment.propertyId,
        "price": widget.isMonthly
            ? (widget.payment.price)
            : (double.tryParse(_fields.text("amount").replaceAll(",", ".")) ??
                  (widget.payment.price)),

        "name": _fields.text("title"),
        "isPayed": widget.payment.isPayed == true,
        "comment": _fields.text("comment"),
        "monthNumber": widget.isMonthly ? widget.payment.monthNumber : 0,
        "yearNumber": widget.isMonthly ? widget.payment.yearNumber : 0,
        "dateToPay": DateHelper.toUtcIsoNullable(_dateToPay),
        "warningDateToPay": DateHelper.toUtcIsoNullable(_warningDateToPay),
      };

      if (!widget.isMonthly) {
        req["price"] =
            double.tryParse(_fields.text("amount").replaceAll(",", ".")) ??
            widget.payment.price;
      }

      await _paymentProvider.update(widget.payment.id, req);

      SnackbarHelper.showSuccess(context, "Zahtjev uspješno ažuriran.");
      Navigator.pop(context, true);
    } catch (e) {
      SnackbarHelper.showError(context, "Greška prilikom ažuriranja zahtjeva.");
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
    final periodText = widget.isMonthly
        ? "(${widget.payment.monthNumber}.${widget.payment.yearNumber})"
        : "(kratki boravak)";

    final isAmountEnabled =
        !_isReadOnly && !widget.isMonthly; // ✅ short stay enabled

    return RentifyBasePage(
      title:
          "Uredi zahtjev: ${widget.user.firstName} ${widget.user.lastName} $periodText",
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nekretnina: ${widget.property?.name ?? "-"}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              const Text("Naziv:*"),
              const SizedBox(height: 5),
              TextField(
                enabled: !_isReadOnly,
                controller: _fields.controller("title"),
                decoration: _decoration("title"),
              ),

              const SizedBox(height: 20),

              const Text("Iznos:*"),
              const SizedBox(height: 5),
              TextField(
                enabled: false,
                controller: _fields.controller("amount"),
                keyboardType: TextInputType.number,
                decoration: _decoration("amount"),
              ),

              const SizedBox(height: 20),

              const Text("Datum do kad se treba platiti:*"),
              const SizedBox(height: 5),
              TextField(
                enabled: !_isReadOnly,
                controller: _dateToPayCtrl,
                readOnly: true,
                onTap: _isReadOnly
                    ? null
                    : () => _pickDate(
                        initial: _dateToPay,
                        onPicked: (d) {
                          setState(() {
                            _dateToPay = d;
                            _dateToPayCtrl.text = DateHelper.format(d);
                            _errors.remove("dateToPay");

                            // Ako warning ode iza roka, očisti ga
                            if (_warningDateToPay != null &&
                                _warningDateToPay!.isAfter(d)) {
                              _warningDateToPay = null;
                              _warningDateCtrl.clear();
                            }
                          });
                        },
                      ),
                decoration: _decoration("dateToPay").copyWith(
                  hintText: "Odaberite datum",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: _isReadOnly
                        ? null
                        : () => _pickDate(
                            initial: _dateToPay,
                            onPicked: (d) {
                              setState(() {
                                _dateToPay = d;
                                _dateToPayCtrl.text = DateHelper.format(d);
                                _errors.remove("dateToPay");

                                if (_warningDateToPay != null &&
                                    _warningDateToPay!.isAfter(d)) {
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
                enabled: !_isReadOnly,
                controller: _warningDateCtrl,
                readOnly: true,
                onTap: _isReadOnly
                    ? null
                    : () => _pickDate(
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
                  hintText: "Odaberite datum",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.notification_important_outlined),
                    onPressed: _isReadOnly
                        ? null
                        : () => _pickDate(
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
                enabled: !_isReadOnly,
                controller: _fields.controller("comment"),
                maxLines: 5,
                decoration: _decoration(
                  "comment",
                ).copyWith(contentPadding: const EdgeInsets.all(10)),
              ),

              const SizedBox(height: 30),

              if (!_isReadOnly)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Sačuvaj izmjene"),
                  ),
                )
              else
                const Text(
                  "Ova uplata je zaključana jer je plaćena.",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
