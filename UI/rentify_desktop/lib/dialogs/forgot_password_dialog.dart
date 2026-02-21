import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/providers/user_provider.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  // 🎨 Rentify theme
  static const Color _green = Color(0xFF5F9F3B);
  static const Color _greenSoft = Color(0xFFEAF6E5);
  static const Color _text = Color(0xFF1F2A1F);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFDFE6DA);
  static const double _radius = 18;

  final TextEditingController _emailController = TextEditingController();

  String? error;
  String? success;
  bool isLoading = false;

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(email);
  }

  Future<void> _submit() async {
    setState(() {
      error = null;
      success = null;
    });

    final email = _emailController.text.trim();

    if (!_isValidEmail(email)) {
      setState(() => error = "Unesite ispravan email.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.forgotPassword(email);

      if (!mounted) return;

      setState(() {
        success = "Email je poslan. Provjerite inbox/spam folder.";
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error = "Neuspješno slanje. Provjerite email ili pokušajte ponovo.";
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: "Email adresa",
      prefixIcon: const Icon(Icons.email_outlined, size: 20, color: _green),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _green, width: 1.6),
      ),
    );
  }

  Widget _messageBox({
    required String text,
    required bool isError,
  }) {
    final bg = isError ? const Color(0xFFFFE8E8) : const Color(0xFFEAF6E5);
    final fg = isError ? const Color(0xFFE53935) : _green;
    final icon = isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 12.8,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🟩 HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: const BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(_radius)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lock_reset_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Zaboravljena lozinka",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              // BODY
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Unesite email povezan sa vašim nalogom i poslat ćemo vam novu lozinku.",
                      style: TextStyle(
                        fontSize: 13.2,
                        fontWeight: FontWeight.w700,
                        color: _muted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onSubmitted: (_) => isLoading ? null : _submit(),
                      decoration: _inputDecoration(),
                    ),

                    if (error != null) ...[
                      const SizedBox(height: 12),
                      _messageBox(text: error!, isError: true),
                    ],

                    if (success != null) ...[
                      const SizedBox(height: 12),
                      _messageBox(text: success!, isError: false),
                    ],

                    const SizedBox(height: 16),

                    // ACTIONS
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _muted,
                            side: BorderSide(color: _muted.withOpacity(0.35)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Zatvori",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            isLoading ? "Slanje..." : "Pošalji mail",
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}