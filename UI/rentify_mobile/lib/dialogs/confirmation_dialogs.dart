import 'package:flutter/material.dart';

enum TriConfirmResult { cancel, bad, good }

class ConfirmDialogs {
  ConfirmDialogs._();

  static const Color _primaryGreen = Color(0xFF5F9F3B);
  static const Color _dangerRed = Color(0xFFE53935);
  static const Color _warningOrange = Color(0xFFF59E0B);
  static const Color _text = Color(0xFF374151);
  static const Color _muted = Color(0xFF6B7280);

  static const double _radius = 14;

  static Future<T?> _baseDialog<T>(
    BuildContext context, {
    required String title,
    required String message,
    required List<Widget> actions,
    bool barrierDismissible = false,
    bool showClose = true,
    T? closeValue,
    Color headerColor = _primaryGreen,
    IconData? headerIcon,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(_radius),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (headerIcon != null) ...[
                        Icon(
                          headerIcon,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (showClose) ...[
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () =>
                              Navigator.of(dialogContext).pop(closeValue),
                          borderRadius: BorderRadius.circular(10),
                          child: Ink(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.22),
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: _text,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static ButtonStyle _outlineBtn({required Color color}) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color, width: 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  static ButtonStyle _filledBtn({required Color bg, Color fg = Colors.white}) {
    return ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  static Future<bool> yesNoConfirmation(
    BuildContext context, {
    required String question,
    String title = 'Potvrda',
    String yesText = 'Da',
    String noText = 'Ne',
    bool barrierDismissible = false,
  }) async {
    final res = await _baseDialog<bool>(
      context,
      title: title,
      message: question,
      barrierDismissible: barrierDismissible,
      closeValue: false,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: _outlineBtn(color: _muted),
          child: Text(
            noText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: _filledBtn(bg: _primaryGreen),
          child: Text(
            yesText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
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
    await _baseDialog<void>(
      context,
      title: title,
      message: message,
      barrierDismissible: barrierDismissible,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: _filledBtn(bg: _primaryGreen),
          child: Text(
            okText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  static Future<bool?> badGoodConfirmation(
    BuildContext context, {
    required String question,
    String title = 'Potvrda',
    required String goodText,
    required String badText,
    bool barrierDismissible = false,
    bool goodIsGreen = true,
  }) async {
    final res = await _baseDialog<bool?>(
      context,
      title: title,
      message: question,
      barrierDismissible: barrierDismissible,
      closeValue: null,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: _outlineBtn(color: _dangerRed),
          child: Text(
            badText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: _filledBtn(bg: goodIsGreen ? _primaryGreen : _primaryGreen),
          child: Text(
            goodText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );

    return res;
  }

  static Future<bool?> badGoodConfirmationWithDisable(
    BuildContext context, {
    required String question,
    String title = 'Potvrda',
    required String goodText,
    required String badText,
    bool barrierDismissible = false,
    bool goodIsGreen = true,
    bool goodEnabled = true,
    String? goodDisabledHint,
  }) async {
    final msg = (!goodEnabled && (goodDisabledHint ?? "").trim().isNotEmpty)
        ? "$question\n\nℹ️ ${goodDisabledHint!.trim()}"
        : question;

    final res = await _baseDialog<bool?>(
      context,
      title: title,
      message: msg,
      barrierDismissible: barrierDismissible,
      showClose: true,
      closeValue: null,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: _outlineBtn(color: _dangerRed),
          child: Text(
            badText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: goodEnabled ? () => Navigator.of(context).pop(true) : null,
          style: _filledBtn(bg: goodIsGreen ? _primaryGreen : _primaryGreen),
          child: Text(
            goodText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );

    return res;
  }

  static Future<void> paymentSuccessDialog(
    BuildContext context, {
    String title = "Plaćanje uspješno",
    String message = "Plaćanje je uspješno evidentirano.",
    String okText = "U redu",
    bool barrierDismissible = false,
  }) async {
    await _baseDialog<void>(
      context,
      title: title,
      message: message,
      barrierDismissible: barrierDismissible,
      headerColor: _primaryGreen,
      headerIcon: Icons.check_circle_rounded,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: _filledBtn(bg: _primaryGreen),
          child: Text(
            okText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  static Future<void> paymentFailedDialog(
    BuildContext context, {
    String title = "Plaćanje nije uspjelo",
    String message =
        "Plaćanje nije uspješno završeno. Pokušajte ponovo ili provjerite podatke kartice.",
    String okText = "U redu",
    bool barrierDismissible = false,
  }) async {
    await _baseDialog<void>(
      context,
      title: title,
      message: message,
      barrierDismissible: barrierDismissible,
      headerColor: _dangerRed,
      headerIcon: Icons.cancel_rounded,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: _filledBtn(bg: _dangerRed),
          child: Text(
            okText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  static Future<void> paymentErrorDialog(
    BuildContext context, {
    String title = "Greška pri provjeri",
    String message =
        "Došlo je do greške pri provjeri statusa plaćanja. Molimo pokušajte ponovo kasnije.",
    String okText = "U redu",
    bool barrierDismissible = false,
  }) async {
    await _baseDialog<void>(
      context,
      title: title,
      message: message,
      barrierDismissible: barrierDismissible,
      headerColor: _warningOrange,
      headerIcon: Icons.error_outline_rounded,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: _filledBtn(bg: _warningOrange),
          child: Text(
            okText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}