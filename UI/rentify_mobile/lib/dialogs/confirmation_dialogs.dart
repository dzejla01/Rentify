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
      barrierColor: Colors.black.withValues(alpha: 0.4),
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
                        Icon(headerIcon, color: Colors.white, size: 22),
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
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
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

  static Future<String?> reasonPrompt(
    BuildContext context, {
    required String title,
    String message = 'Molimo unesite razlog:',
    String confirmText = 'Potvrdi',
    String cancelText = 'Otkaži',
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => _ReasonPromptDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
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

class _ReasonPromptDialog extends StatefulWidget {
  const _ReasonPromptDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;

  @override
  State<_ReasonPromptDialog> createState() => _ReasonPromptDialogState();
}

class _ReasonPromptDialogState extends State<_ReasonPromptDialog> {
  late final TextEditingController _controller;
  String? _error;

  static const Color _primaryGreen = Color(0xFF5F9F3B);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _text = Color(0xFF374151);
  static const double _radius = 14;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _error = 'Razlog je obavezan.');
      return;
    }
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(value);
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxDialogHeight =
        (mediaQuery.size.height - mediaQuery.viewInsets.bottom - 48).clamp(
          280.0,
          560.0,
        );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420, maxHeight: maxDialogHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: _primaryGreen,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(_radius),
                ),
              ),
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: _text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      minLines: 3,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Unesite razlog...',
                        errorText: _error,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _cancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _muted,
                            side: const BorderSide(color: _muted, width: 1.2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            widget.cancelText,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            widget.confirmText,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
