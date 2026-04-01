import 'package:flutter/material.dart';
import 'package:rentify_mobile/helper/image_helper.dart';
import 'package:rentify_mobile/routes/app_routes.dart';
import 'package:rentify_mobile/screens/payment_screen.dart';

class BaseMobileScreen extends StatelessWidget {
  const BaseMobileScreen({
    super.key,
    required this.child,
    this.title,
    this.NameAndSurname = "user blank",
    this.userUsername = "blank",
    this.userImageAsset,
    this.onLogout,
    this.leading,
  });

  final Widget child;
  final Widget? leading;
  final String? title;

  final String NameAndSurname;
  final String userUsername;
  final String? userImageAsset;

  final VoidCallback? onLogout;

  static const Color rentifyGreen = Color(0xFFA9C64A);
  static const Color rentifyGreenDark = Color(0xFF5F9F3B);
  static const Color textDark = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: _buildDrawer(context),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        titleSpacing: 16,

        title: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 6),
            ] else ...[
              Image.asset(
                'assets/images/rentify_single_R_green.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
            ],
            Text(
              title ?? "Rentify",
              style: const TextStyle(
                color: textDark,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),

        iconTheme: const IconThemeData(color: textDark),

        actions: [
          Builder(
            builder: (context) => IconButton(
              tooltip: "Menu",
              icon: const Icon(Icons.menu_rounded, size: 28),
              onPressed: () => Scaffold.of(context).openEndDrawer(), // ✅ bitno
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),

      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(child: child),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFBFE06A), rentifyGreen],
                ),
              ),
              child: Row(
                children: [
                  _avatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          NameAndSurname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userUsername,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xEFFFFFFF),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // linija ispod headera
            const Divider(height: 1),

            // Menu stavke
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 6),
                children: [
                  _drawerItem(
                    context,
                    icon: Icons.home_rounded,
                    text: "Početna",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.home);
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.person_rounded,
                    text: "Profil",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.profile);
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.apartment_rounded,
                    text: "Nekretnine",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.properties);
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.calendar_month_rounded,
                    text: "Rezervacije",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.reservations);
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.payments_rounded,
                    text: "Plaćanja",
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.backpack,
                    text: "Termini",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.appointments);
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.favorite_rounded,
                    text: "Favoriti",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.favorites);
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.question_answer_rounded,
                    text: "Pitanja",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.questions);
                    },
                  ),

                  const SizedBox(height: 8),
                  const Divider(height: 1),

                  _drawerItem(
                    context,
                    icon: Icons.logout_rounded,
                    text: "Odjava",
                    danger: true,
                    onTap: () {
                      Navigator.pop(context);
                      if (onLogout != null) onLogout!();
                    },
                  ),
                ],
              ),
            ),

            // Footer mali
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, size: 18, color: Color(0xFF8A8A8A)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Rentify mobile • v1.0",
                      style: TextStyle(
                        color: Color(0xFF8A8A8A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    Widget avatarContent;

    if (ImageHelper.hasValidImage(userImageAsset)) {
      avatarContent = Image.network(
        ImageHelper.safeUserImageUrl(userImageAsset),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.person_rounded, color: Colors.white, size: 34),
      );
    } else {
      avatarContent = const Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 34,
      );
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: avatarContent,
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? Colors.red.shade600 : textDark;

    return ListTile(
      leading: Icon(
        icon,
        color: danger ? Colors.red.shade600 : rentifyGreenDark,
      ),
      title: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
      onTap: onTap,
      horizontalTitleGap: 10,
      dense: true,
    );
  }
}
