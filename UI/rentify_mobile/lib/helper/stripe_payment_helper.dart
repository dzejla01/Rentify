import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/providers/payment_provider.dart';

class StripePaymentHelper {
  static Future<bool> payPayment(
    BuildContext context, {
    required int paymentId,
    required int userId,
    required int propertyId,
    required bool isMonthly,
    required int monthNumber,
    required int yearNumber,
  }) async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();

      final provider = context.read<PaymentProvider>();

      final clientSecret = await provider.createNewIntent({
        "paymentId": paymentId,
        "userId": userId,
        "propertyId": propertyId,
        "isMonthly": isMonthly,
        "monthNumber": isMonthly ? monthNumber : 0,
        "yearNumber": isMonthly ? yearNumber : 0,
      });

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: const SetupPaymentSheetParameters(
          merchantDisplayName: "Rentify",
          style: ThemeMode.light,
          paymentIntentClientSecret: null,
        ).copyWith(
          paymentIntentClientSecret: clientSecret,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      debugPrint(
        "StripeException: ${e.error.localizedMessage ?? e.error.message}",
      );
      return false;
    } catch (e) {
      debugPrint("Stripe payment error: $e");
      return false;
    }
  }
}