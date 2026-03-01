import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/providers/payment_provider.dart';

class StripePaymentHelper {
  static Future<bool> pay(BuildContext context, {required int paymentId}) async {
    try {
      FocusManager.instance.primaryFocus?.unfocus(); 

      final provider = context.read<PaymentProvider>();
      final clientSecret = await provider.createStripeIntent(paymentId);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "Rentify",
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      debugPrint("StripeException: ${e.error.localizedMessage ?? e.error.message}");
      return false;
    }
  }
}