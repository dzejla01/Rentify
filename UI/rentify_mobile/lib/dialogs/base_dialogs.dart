import 'package:flutter/material.dart';

class RentifyBaseDialog extends StatelessWidget {
  RentifyBaseDialog({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
    this.width = 520,
    this.height,
  });

  final String title;
  final Widget child;
  VoidCallback? onClose;
  final double width;
  final double? height;

  static const Color textDark = Color(0xFF4A4A4A);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 26,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 HEADER
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF5F9F3B), 
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
                child: Row(
                  children: [
                    const SizedBox(width: 40, height: 40),

                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white, 
                        ),
                      ),
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white, 
                      ),
                      splashRadius: 20,
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),
            ),

            // divider
            Container(height: 1, color: Colors.black.withOpacity(0.06)),

            // 🔹 CONTENT
            Flexible(
              child: Padding(padding: const EdgeInsets.all(20), child: child),
            ),
          ],
        ),
      ),
    );
  }
}
    