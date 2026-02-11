import 'package:flutter/material.dart';

class RentifyBasePage extends StatelessWidget {
  const RentifyBasePage({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.logoAsset = 'assets/images/rentify_single_R_green.png',
  });

  final String title;
  final Widget child;
  final Future<bool> Function()? onBack;
  final String logoAsset;

  static const Color rentifyGreen = Color(0xFFA9C64A);
  static const Color textDark = Color(0xFF4A4A4A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            _header(
              context: context,
              title: title,
              onBack: () async {
                if (onBack == null) {
                  Navigator.of(context).pop();
                  return;
                }

                final allow = await onBack!.call();
                if (!context.mounted) return;

                if (allow) {
                  Navigator.of(context).pop(true);
                }
              },
              logoAsset: logoAsset,
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header({
    required BuildContext context,
    required String title,
    required Future<void> Function() onBack,
    required String logoAsset,
  }) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.06), // suptilna linija
            width: 1,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), // jako slaba sjena
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Row(
            children: [
              // LEFT: Back
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap:  onBack,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: rentifyGreen,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // CENTER: pill title
              Expanded(
                child: Center(
                  child: Container(
                    width: 500,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: rentifyGreen.withOpacity(0.85),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000), // mikro sjena pill-a
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // RIGHT: logo
              SizedBox(
                width: 70,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    logoAsset,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
