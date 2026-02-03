import 'package:flutter/material.dart';

class ConfirmDialogs {
  ConfirmDialogs._();

  
  static Future<bool> yesNoConfirmation(
    BuildContext context, {
    required String question,
    String title = 'Potvrda',
    String yesText = 'Da',
    String noText = 'Ne',
    bool barrierDismissible = false,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(question),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(noText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(yesText),
          ),
        ],
      ),
    );

    return res ?? false;
  }

  
  static Future<void> okConfirmation(
    BuildContext context, {
    required String message,
    String title = 'Informacija',
    String okText = 'OK',
    bool barrierDismissible = false,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(okText),
          ),
        ],
      ),
    );
  }

  
  static Future<bool> badGoodConfirmation(
    BuildContext context, {
    required String question,
    String title = 'Potvrda',
    required String goodText,
    required String badText,
    bool barrierDismissible = false,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(question),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(badText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5F9F3B), // tvoj green
              foregroundColor: Colors.white,
            ),
            child: Text(goodText),
          ),
        ],
      ),
    );

    return res ?? false;
  }
}
