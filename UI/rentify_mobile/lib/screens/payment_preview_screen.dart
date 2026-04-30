import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/dialogs/confirmation_dialogs.dart';
import 'package:rentify_mobile/helper/stripe_payment_helper.dart';
import 'package:rentify_mobile/providers/auth_provider.dart';
import 'package:rentify_mobile/providers/device_token_provider.dart';
import 'package:rentify_mobile/routes/app_routes.dart';
import 'package:rentify_mobile/screens/base_screen.dart';
import 'package:rentify_mobile/utils/session.dart';
import 'package:rentify_mobile/models/payment.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/providers/payment_provider.dart';

class PaymentPreviewScreen extends StatefulWidget {
  const PaymentPreviewScreen({
    super.key,
    required this.payment,
    required this.property,
    required this.isMonthly,
  });

  final Payment payment;
  final Property property;
  final bool isMonthly;

  @override
  State<PaymentPreviewScreen> createState() => _PaymentPreviewScreenState();
}

class _PaymentPreviewScreenState extends State<PaymentPreviewScreen> {
  late PaymentProvider _paymentProvider;

  bool _loading = false;
  String? _error;

  Payment get p => widget.payment;

  String get _paymentStatus => (p.paymentStatus).trim();

  @override
  void initState() {
    super.initState();
    _paymentProvider = context.read<PaymentProvider>();
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return "-";
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return "$dd.$mm.$yy";
  }

  String _periodText() {
    if (!widget.isMonthly) return "Kratki boravak";
    final m = p.monthNumber.toString().padLeft(2, '0');
    return "$m.${p.yearNumber}";
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isAdditionalDeadlineActive() {
    if (_paymentStatus == "Plaćeno" ||
        _paymentStatus == "Neplaćeno" ||
        _paymentStatus == "Otkazano" ||
        _paymentStatus == "Neuspješno") {
      return false;
    }

    if (p.dateToPay == null) return false;
    if (p.secondWarningDate == null) return false;

    final today = _dateOnly(DateTime.now());
    final dueDate = _dateOnly(p.dateToPay!);

    return !today.isBefore(dueDate);
  }

  bool _isUnpaid() {
    return _paymentStatus == "Neplaćeno";
  }

  bool _canPay() {
    return _paymentStatus == "Na čekanju" || _paymentStatus == "Procesiranje";
  }

  String _additionalDeadlineMessage() {
    if (p.secondWarningDate != null) {
      return "Prvi rok plaćanja nije ispoštovan. Dodijeljen vam je dodatni rok do ${_fmtDate(p.secondWarningDate)}. Ako uplata ne bude evidentirana ni do tada, zahtjev će biti završen zbog neplaćenog duga.";
    }

    return "Prvi rok plaćanja nije ispoštovan. Dodijeljen vam je dodatni rok. Ako uplata ne bude evidentirana ni u dodatnom roku, zahtjev će biti završen zbog neplaćenog duga.";
  }

  String _unpaidMessage() {
    return "Ovaj zahtjev je označen kao neplaćen zbog neizmirene obaveze u predviđenom roku.";
  }

  Future<void> _payNow() async {
    if (!_canPay()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final stripeSuccess = await StripePaymentHelper.payPayment(
        context,
        paymentId: p.id,
        userId: Session.userId!,
        propertyId: p.reservation!.propertyId,
        isMonthly: widget.isMonthly,
        monthNumber: widget.isMonthly ? p.monthNumber : 0,
        yearNumber: widget.isMonthly ? p.yearNumber : 0,
      );

      if (!stripeSuccess) {
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }

      await Future.delayed(const Duration(seconds: 4));

      final refreshed = await _paymentProvider.getById(p.id);

      if (!mounted) return;

      setState(() => _loading = false);

      final status = (refreshed.paymentStatus).trim();

      if (status == "Plaćeno") {
        await ConfirmDialogs.paymentSuccessDialog(
          context,
          message: "Plaćanje je uspješno evidentirano.",
        );

        if (!mounted) return;
        Navigator.pop(context, true);
        return;
      }

      if (status == "Neuspješno") {
        await ConfirmDialogs.paymentFailedDialog(
          context,
          message: "Plaćanje nije uspješno završeno.",
        );

        if (!mounted) return;
        Navigator.pop(context, true);
        return;
      }

      if (status == "Otkazano") {
        await ConfirmDialogs.paymentFailedDialog(
          context,
          message: "Plaćanje je otkazano.",
        );

        if (!mounted) return;
        Navigator.pop(context, true);
        return;
      }

      await ConfirmDialogs.paymentErrorDialog(
        context,
        message:
            "Status plaćanja još nije potvrđen ili je došlo do greške na serveru. Provjerite ponovo za nekoliko sekundi.",
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });

      await ConfirmDialogs.paymentErrorDialog(
        context,
        message:
            "Došlo je do greške pri provjeri statusa plaćanja. Pokušajte ponovo kasnije.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAdditionalDeadline = _isAdditionalDeadlineActive();
    final isUnpaid = _isUnpaid();

    return BaseMobileScreen(
      title: "Zahtjev za uplatu",
      NameAndSurname: Session.fullName!,
      userUsername: Session.username ?? "Nepoznato",
      userImageAsset: Session.userImage,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      onLogout: () async {
        await Session.odjava(
          deviceTokenProvider: context.read<DeviceTokenProvider>(),
          authProvider: context.read<AuthProvider>(),
        );

        if (!context.mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      },
      child: Container(
        color: const Color(0xFFF6F7FB),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                children: [
                  if (hasAdditionalDeadline) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE53935),
                          width: 1.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53935).withOpacity(0.10),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Dodatni rok",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFD32F2F),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _additionalDeadlineMessage(),
                                  style: const TextStyle(
                                    color: Color(0xFF7F1D1D),
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (isUnpaid) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE53935),
                          width: 1.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53935).withOpacity(0.10),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _unpaidMessage(),
                              style: const TextStyle(
                                color: Color(0xFF7F1D1D),
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  _Card(
                    borderColor: hasAdditionalDeadline || isUnpaid
                        ? const Color(0xFFE53935)
                        : null,
                    borderWidth: hasAdditionalDeadline || isUnpaid ? 1.8 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.property.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${widget.property.city} • ${widget.property.location}",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _Chip(
                              icon: Icons.category_rounded,
                              label: widget.isMonthly
                                  ? "Najamnina"
                                  : "Kratki boravak",
                            ),
                            _Chip(
                              icon: Icons.calendar_month_outlined,
                              label: _periodText(),
                            ),
                            _Chip(
                              icon: hasAdditionalDeadline
                                  ? Icons.warning_amber_rounded
                                  : isUnpaid
                                  ? Icons.error_outline_rounded
                                  : Icons.event_busy_outlined,
                              label: hasAdditionalDeadline
                                  ? "Dodatni rok: ${_fmtDate(p.secondWarningDate)}"
                                  : "Rok: ${_fmtDate(p.dateToPay)}",
                              backgroundColor: hasAdditionalDeadline || isUnpaid
                                  ? const Color(0xFFFFEBEE)
                                  : null,
                              foregroundColor: hasAdditionalDeadline || isUnpaid
                                  ? const Color(0xFFD32F2F)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _Card(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.receipt_long_outlined),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Iznos",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          "${p.price.toStringAsFixed(2)} KM",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Detalji zahtjeva",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 10),
                        _InfoRow(
                          label: "Status",
                          valueWidget: _StatusText(
                            paymentStatus: _paymentStatus,
                            additionalDeadline: hasAdditionalDeadline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: "Rok plaćanja",
                          value: _fmtDate(p.dateToPay),
                        ),
                        if (hasAdditionalDeadline &&
                            p.secondWarningDate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _InfoRow(
                              label: "Dodatni rok",
                              value: _fmtDate(p.secondWarningDate),
                              valueColor: const Color(0xFFD32F2F),
                            ),
                          ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Komentar",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (p.comment.trim().isEmpty)
                              ? "Nema dodatnog komentara."
                              : p.comment,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_canPay())
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _payNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasAdditionalDeadline
                              ? const Color(0xFFD32F2F) // danger
                              : const Color(0xFF9C27B0), // Rentify primary
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Icon(
                          hasAdditionalDeadline
                              ? Icons.warning_amber_rounded
                              : Icons.payments_rounded,
                          size: 22,
                        ),
                        label: Text(
                          hasAdditionalDeadline
                              ? "Platite u dodatnom roku (${p.price.toStringAsFixed(2)} KM)"
                              : "Plati zahtjev (${p.price.toStringAsFixed(2)} KM)",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _paymentStatus == "Plaćeno"
                            ? Colors.green.withOpacity(0.08)
                            : Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _paymentStatus == "Plaćeno"
                            ? "Ovaj zahtjev je već plaćen."
                            : _paymentStatus == "Neplaćeno"
                            ? "Ovaj zahtjev je označen kao neplaćen."
                            : _paymentStatus == "Otkazano"
                            ? "Ovaj zahtjev je otkazan."
                            : _paymentStatus == "Neuspješno"
                            ? "Plaćanje nije uspješno završeno."
                            : "Za ovaj zahtjev trenutno nije moguće izvršiti uplatu.",
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.borderColor, this.borderWidth});

  final Widget child;
  final Color? borderColor;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: borderWidth ?? 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.black.withOpacity(0.05);
    final fgColor = foregroundColor ?? const Color(0xFF111827);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fgColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w700, color: fgColor),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.valueColor,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            "$label:",
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child:
              valueWidget ??
              Text(
                value ?? "-",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? const Color(0xFF111827),
                ),
              ),
        ),
      ],
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({
    required this.paymentStatus,
    required this.additionalDeadline,
  });

  final String paymentStatus;
  final bool additionalDeadline;

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color color;

    if (paymentStatus == "Plaćeno") {
      text = "Plaćeno";
      color = Colors.green;
    } else if (paymentStatus == "Neplaćeno") {
      text = "Neplaćeno";
      color = const Color(0xFFD32F2F);
    } else if (paymentStatus == "Otkazano") {
      text = "Otkazano";
      color = Colors.grey;
    } else if (paymentStatus == "Neuspješno") {
      text = "Neuspješno";
      color = Colors.deepOrange;
    } else if (additionalDeadline) {
      text = "Dodatni rok";
      color = const Color(0xFFD32F2F);
    } else if (paymentStatus == "Procesiranje") {
      text = "Procesiranje";
      color = Colors.blue;
    } else {
      text = "Na čekanju";
      color = Colors.orange;
    }

    return Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w800),
    );
  }
}
