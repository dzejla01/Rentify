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

  Future<void> _payNow() async {
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

      final status = (refreshed.paymentStatus ?? "").trim().toLowerCase();

      if (status == "paid") {
        await ConfirmDialogs.paymentSuccessDialog(
          context,
          message: "Plaćanje je uspješno evidentirano.",
        );

        if (!mounted) return;
        Navigator.pop(context, true);
        return;
      }

      if (status == "failed") {
        await ConfirmDialogs.paymentFailedDialog(
          context,
          message: "Plaćanje nije uspješno završeno.",
        );

        if (!mounted) return;
        Navigator.pop(context, true);
        return;
      }

      if (status == "canceled") {
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
  void initState() {
    super.initState();
    _paymentProvider = context.read<PaymentProvider>();
  }

  @override
  Widget build(BuildContext context) {
    final isPayed = p.isPayed == true;

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
                  _Card(
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
                              icon: Icons.event_busy_outlined,
                              label: "Rok: ${_fmtDate(p.dateToPay)}",
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
                          "Komentar",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p.comment,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              "Status:",
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(width: 8),
                            _StatusText(isPayed: isPayed),
                          ],
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 10),
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

                  const SizedBox(height: 16),

                  if (!isPayed)
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _payNow,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.payments_rounded),
                        label: Text(
                          "Plati zahtjev (${p.price.toStringAsFixed(2)} KM)",
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        "Ovaj zahtjev je već plaćen.",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.isPayed});
  final bool isPayed;

  @override
  Widget build(BuildContext context) {
    return Text(
      isPayed ? "Uplaćeno" : "Na čekanju",
      style: TextStyle(
        color: isPayed ? Colors.green : Colors.orange,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
