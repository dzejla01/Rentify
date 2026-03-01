import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/helper/date_helper.dart';
import 'package:rentify_mobile/helper/tags.dart';

import 'package:rentify_mobile/routes/app_routes.dart';
import 'package:rentify_mobile/utils/session.dart';
import 'package:rentify_mobile/config/token_storage.dart';
import 'package:rentify_mobile/providers/user_provider.dart';
import 'package:rentify_mobile/helper/snackBar_helper.dart';
import 'package:rentify_mobile/screens/login_screen.dart';

class TaggsOnboardingScreen extends StatefulWidget {
  const TaggsOnboardingScreen({super.key});

  @override
  State<TaggsOnboardingScreen> createState() => _TaggsOnboardingScreenState();
}

class _TaggsOnboardingScreenState extends State<TaggsOnboardingScreen> {
  final _searchCtrl = TextEditingController();

  late final List<_TagItem> _all = allTags
      .map((t) => _TagItem(t, _iconForTag(t)))
      .toList();

  final Set<String> _selected = {};
  bool _saving = false;

  String? _fullName;
  bool _loadingUser = true;

  Future<void> _loadUserName() async {
  try {
    final id = Session.userId;
    if (id == null) return;

    final user = await context.read<UserProvider>().getById(id);
    if (!mounted) return;

    setState(() {
      _fullName = "${user.firstName} ${user.lastName}".trim();
      _loadingUser = false;
    });
  } catch (_) {
    if (!mounted) return;
    setState(() => _loadingUser = false);
  }
}

  @override
  void initState() {
    super.initState();
    // Ako već imaš lokalno snimljene tagove, možeš ih učitati (opc.)
    _loadUserName();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    try {
      final existing = await TokenStorage.readTaggs();
      if (!mounted) return;
      setState(() => _selected.addAll(existing));
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_TagItem> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((t) => t.label.toLowerCase().contains(q)).toList();
  }

  IconData _iconForTag(String tag) {
    // Property type & style
    const home = {
      'Apartment',
      'House',
      'Studio',
      'Loft',
      'Minimalist',
      'Modern',
      'Traditional',
      'Elegant',
      'Family Home',
    };
    if (home.contains(tag)) return Icons.home_outlined;

    // Location & position
    const location = {
      'City Center',
      'Old Town',
      'Quiet Neighborhood',
      'Urban Area',
      'Riverside',
      'Lake View',
      'City View',
      'Panoramic View',
      'Corner Unit',
      'Elevated',
    };
    if (location.contains(tag)) return Icons.place_outlined;

    // Atmosphere & feel
    const vibe = {
      'Bright',
      'Sunny',
      'Warm',
      'Airy',
      'Calm',
      'Quiet',
      'Relaxing',
      'Balanced',
      'Comfortable',
    };
    if (vibe.contains(tag)) return Icons.wb_sunny_outlined;

    // Layout & space
    const layout = {
      'Spacious',
      'Compact',
      'Efficient Layout',
      'Open Space',
      'Open Plan',
    };
    if (layout.contains(tag)) return Icons.space_dashboard_outlined;

    // Features
    const features = {
      'Balcony',
      'Terrace',
      'Parking',
      'Elevator',
      'Walk-in Closet',
      'Storage Room',
    };
    if (features.contains(tag)) return Icons.star_border_rounded;

    // Usage & target
    const target = {
      'Family Friendly',
      'Student Friendly',
      'Single Living',
      'Business Ready',
    };
    if (target.contains(tag)) return Icons.group_outlined;

    // Surroundings
    const around = {
      'Near School',
      'Near University',
      'Near Market',
      'Walkable Area',
      'Close to Public Transport',
      'Green Area',
    };
    if (around.contains(tag)) return Icons.directions_walk_outlined;

    // Quality & condition
    const quality = {
      'New Build',
      'Newly Renovated',
      'Well Maintained',
      'Exclusive',
      'Authentic',
      'Historic',
      'Creative Space',
    };
    if (quality.contains(tag)) return Icons.verified_outlined;

    // Lifestyle
    const lifestyle = {'Pet Friendly', 'Long Term Rental', 'Short Term Rental'};
    if (lifestyle.contains(tag)) return Icons.favorite_border;

    return Icons.local_offer_outlined;
  }

  Future<void> _saveAndContinue() async {
    FocusScope.of(context).unfocus();

    if (_selected.isEmpty) {
      SnackbarHelper.showError(context, "Odaberi bar 1 interesovanje.");
      return;
    }

    setState(() => _saving = true);

    try {
      final taggs = _selected.toList();
      Session.taggs = taggs;

      // 1) lokalno snimi
      await TokenStorage.saveTaggs(taggs);

      final user = await context.read<UserProvider>().getById(Session.userId!);

      await context.read<UserProvider>().update(Session.userId!, {
        "firstName": user.firstName,
        "lastName": user.lastName,
        "email": user.email,
        "username": user.username,
        "phoneNumber": user.phoneNumber,
        "dateOfBirth": DateHelper.toUtcIsoNullable(user.dateOfBirth),
        "isLoggingFirstTime": false,
        "isActive": true,
        "preferedTagsIfNoReservations": taggs,
      });

      // 3) ugasi flag u memoriji
      Session.isLoggingFirstTime = false;

      if (!mounted) return;

      // 4) idi na Home
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(
        context,
        "Greška pri spremanju tagova. Pokušaj ponovo. ${e}",
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toggle(String label) {
    setState(() {
      if (_selected.contains(label)) {
        _selected.remove(label);
      } else {
        if (_selected.length >= 8) {
          // limit da UX bude čist
          SnackbarHelper.showError(context, "Možeš odabrati najviše 8 tagova.");
          return;
        }
        _selected.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBFE06A), LoginScreen.rentifyGreen],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // soft circles for “premium” feel
              Positioned(top: -40, right: -30, child: _blurCircle(110)),
              Positioned(bottom: 90, left: -50, child: _blurCircle(130)),

              // main card
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 24,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F8E4),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: LoginScreen.rentifyGreenDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Personalizuj preporuke",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: LoginScreen.textDark,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Odaberi šta najviše voliš na putovanjima.",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF6E6E6E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Step indicator
                          Row(
                            children: [
                              _pill("Korak 1/1", Icons.flag_outlined),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: 1,
                                    minHeight: 8,
                                    backgroundColor: const Color(0xFFEDEDED),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          LoginScreen.rentifyGreenDark,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Search
                          TextField(
                            controller: _searchCtrl,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              hintText: "Pretraži tagove (npr. more, hrana...)",
                              filled: true,
                              fillColor: const Color(0xFFF7F7F7),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: LoginScreen.rentifyGreen,
                              ),
                              suffixIcon: _searchCtrl.text.trim().isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() {});
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        color: Color(0xFF8A8A8A),
                                      ),
                                    ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: LoginScreen.rentifyGreen,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Selected counter + hint
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Odabrano: ${_selected.length}/8",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: LoginScreen.textDark,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Color(0xFF8A8A8A),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                "možeš kasnije promijeniti",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF8A8A8A),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Chips grid
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final t in items)
                                _FancyChip(
                                  label: t.label,
                                  icon: t.icon,
                                  selected: _selected.contains(t.label),
                                  onTap: () => _toggle(t.label),
                                ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // subtle explanation box
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F8E4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2EEC1),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: LoginScreen.rentifyGreenDark,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Dok još nemaš rezervacija, ove preference pomažu Rentify-ju da ti odmah prikazuje ponude po ukusu.",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF3A3A3A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // bottom bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 18,
                          offset: Offset(0, -8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selected.isEmpty
                                ? "Odaberi bar 1 tag"
                                : "Spremno za preporuke ✨",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: LoginScreen.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _saveAndContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LoginScreen.rentifyGreenDark,
                              foregroundColor: Colors.white,
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Row(
                                    children: [
                                      Text(
                                        "Nastavi",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blurCircle(double size) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: LoginScreen.rentifyGreenDark),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: LoginScreen.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagItem {
  final String label;
  final IconData icon;
  const _TagItem(this.label, this.icon);
}

class _FancyChip extends StatelessWidget {
  const _FancyChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFF3F8E4) : const Color(0xFFF7F7F7);
    final border = selected ? const Color(0xFFBFE06A) : const Color(0xFFEAEAEA);

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: selected ? 1.02 : 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1.3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? LoginScreen.rentifyGreenDark
                    : const Color(0xFF8A8A8A),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: selected
                      ? LoginScreen.textDark
                      : const Color(0xFF4A4A4A),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: LoginScreen.rentifyGreenDark,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
