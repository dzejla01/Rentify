import 'package:flutter/material.dart';

enum TriConfirmResult { cancel, bad, good }

class ConfirmDialogs {
  ConfirmDialogs._();

  // 🎨 Rentify theme
  static const Color _primaryGreen = Color(0xFF5F9F3B);
  static const Color _dangerRed = Color(0xFFE53935);
  static const Color _text = Color(0xFF374151);
  static const Color _muted = Color(0xFF6B7280);

  static const double _radius = 14;

  static Future<T?> _baseDialog<T>(
    BuildContext context, {
    required String title,
    required String message,
    required List<Widget> actions,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🟩 HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: const BoxDecoration(
                    color: _primaryGreen,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_radius),
                    ),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // BODY
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

                // ACTIONS
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  static ButtonStyle _filledBtn({required Color bg, Color fg = Colors.white}) {
    return ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // ✅ 3 opcije: Cancel / Bad / Good
  static Future<TriConfirmResult> badGoodCancel(
    BuildContext context, {
    required String question,
    String title = 'Potvrda',
    required String goodText,
    required String badText,
    String cancelText = 'Zatvori',
    bool barrierDismissible = true,
  }) async {
    final res = await _baseDialog<TriConfirmResult>(
      context,
      title: title,
      message: question,
      barrierDismissible: barrierDismissible,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(TriConfirmResult.cancel),
          style: _outlineBtn(color: _muted),
          child: Text(cancelText, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(TriConfirmResult.bad),
          style: _outlineBtn(color: _dangerRed),
          child: Text(badText, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(TriConfirmResult.good),
          style: _filledBtn(bg: _primaryGreen),
          child: Text(goodText, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );

    return res ?? TriConfirmResult.cancel;
  }

  // ✅ YES / NO
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
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: _outlineBtn(color: _muted),
          child: Text(noText, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: _filledBtn(bg: _primaryGreen),
          child: Text(yesText, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );

    return res ?? false;
  }

  // ✅ OK
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
          child: Text(okText, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  // ✅ BAD / GOOD (brisanje, opasne radnje)
  static Future<bool> badGoodConfirmation(
    BuildContext context, {
    required String question,
    String title = 'Potvrda',
    required String goodText,
    required String badText,
    bool barrierDismissible = false,
    bool goodIsGreen = true, // ostavljeno radi kompatibilnosti
  }) async {
    final res = await _baseDialog<bool>(
      context,
      title: title,
      message: question,
      barrierDismissible: barrierDismissible,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: _outlineBtn(color: _dangerRed),
          child: Text(badText, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: _filledBtn(bg: goodIsGreen ? _primaryGreen : _primaryGreen),
          child: Text(goodText, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );

    return res ?? false;
  }
}