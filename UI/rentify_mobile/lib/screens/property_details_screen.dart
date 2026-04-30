import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/dialogs/base_dialogs.dart';
import 'package:rentify_mobile/dialogs/confirmation_dialogs.dart';
import 'package:rentify_mobile/helper/image_helper.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/models/property_images.dart';
import 'package:rentify_mobile/providers/favorite_provider.dart';
import 'package:rentify_mobile/providers/property_image_provider.dart';
import 'package:rentify_mobile/providers/question_provider.dart';
import 'package:rentify_mobile/providers/reservation_provider.dart';
import 'package:rentify_mobile/screens/property_appointment_screen.dart';
import 'package:rentify_mobile/screens/property_reservation_screen.dart';
import 'package:rentify_mobile/utils/session.dart';

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key, required this.property});

  final Property property;

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  bool _favoriteLoading = false;
  bool _isFavorite = false;
  int? _favoriteId;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
        ),
      );
  }

  Future<void> _loadFavoriteState() async {
    final userId = Session.userId;
    final propertyId = widget.property.id;

    if (userId == null || propertyId == null) return;

    try {
      final favoriteProvider = context.read<FavoriteProvider>();

      final result = await favoriteProvider.get(
        filter: {
          "userId": userId,
          "includeUser": true,
          "propertyId": propertyId,
          "includeProperty": true,
          "page": 0,
          "pageSize": 1,
          "includeTotalCount": false,
        },
      );

      if (!mounted) return;

      setState(() {
        if (result.items.isNotEmpty) {
          _isFavorite = true;
          _favoriteId = result.items.first.id;
        } else {
          _isFavorite = false;
          _favoriteId = null;
        }
      });
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    final userId = Session.userId;
    final propertyId = widget.property.id;

    if (userId == null || propertyId == null) {
      _showSnackBar(
        "Korisnik ili nekretnina nisu dostupni.",
        isError: true,
      );
      return;
    }

    if (_favoriteLoading) return;

    setState(() => _favoriteLoading = true);

    try {
      final favoriteProvider = context.read<FavoriteProvider>();

      if (_isFavorite) {
        if (_favoriteId != null) {
          await favoriteProvider.delete(_favoriteId);
        } else {
          final existing = await favoriteProvider.get(
            filter: {
              "userId": userId,
              "propertyId": propertyId,
              "page": 0,
              "pageSize": 1,
              "includeTotalCount": false,
            },
          );

          if (existing.items.isNotEmpty) {
            await favoriteProvider.delete(existing.items.first.id);
          }
        }

        if (!mounted) return;
        setState(() {
          _isFavorite = false;
          _favoriteId = null;
        });

        _showSnackBar("Nekretnina je uklonjena iz favorita.");
      } else {
        final inserted = await favoriteProvider.insert({
          "userId": userId,
          "propertyId": propertyId,
        });

        if (!mounted) return;
        setState(() {
          _isFavorite = true;
          _favoriteId = inserted.id;
        });

        _showSnackBar("Nekretnina je dodana u favorite.");
      }
    } catch (_) {
      _showSnackBar(
        "Greška pri radu sa favoritima.",
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _favoriteLoading = false);
      }
    }
  }

  Future<void> _openAskQuestionDialog() async {
    final propertyId = widget.property.id;
    final userId = Session.userId;

    if (propertyId == null || userId == null) {
      _showSnackBar(
        "Korisnik ili nekretnina nisu dostupni.",
        isError: true,
      );
      return;
    }

    final sent = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) =>
          _AskQuestionDialog(propertyId: propertyId, userId: userId),
    );

    if (!mounted) return;

    if (sent == true) {
      await ConfirmDialogs.okConfirmation(
        context,
        title: "Pitanje poslano",
        message:
            "Vaše pitanje je uspješno poslano.\n\nOdgovor na pitanje moći ćete vidjeti u sekciji sa pitanjima kada admin odgovori na pitanje.",
      );
    }
  }

  Future<bool> _hasReservationByStatusAndType(
    BuildContext context,
    int propertyId, {
    required bool isMonthly,
    required String status,
  }) async {
    final userId = Session.userId;
    if (userId == null) return false;

    final reservationProvider = context.read<ReservationProvider>();

    final res = await reservationProvider.get(
      filter: {
        "userId": userId,
        "propertyId": propertyId,
        "isMonthly": isMonthly,
        "status": status,
        "page": 0,
        "pageSize": 1,
        "includeTotalCount": false,
      },
    );

    return res.items.isNotEmpty;
  }

  Future<bool> _hasActiveMonthlyRent(
    BuildContext context,
    int propertyId,
  ) async {
    return _hasReservationByStatusAndType(
      context,
      propertyId,
      isMonthly: true,
      status: "Odobreno",
    );
  }

  Future<bool> _hasPendingMonthlyRent(
    BuildContext context,
    int propertyId,
  ) async {
    return _hasReservationByStatusAndType(
      context,
      propertyId,
      isMonthly: true,
      status: "Na čekanju",
    );
  }

  Future<bool> _hasPendingShortStay(
    BuildContext context,
    int propertyId,
  ) async {
    return _hasReservationByStatusAndType(
      context,
      propertyId,
      isMonthly: false,
      status: "Na čekanju",
    );
  }

  Future<void> _handleReservationClick(Property property) async {
    final pid = property.id;

    final supportsShortStay = property.isRentingPerDay;

    final hasPendingMonthly = await _hasPendingMonthlyRent(context, pid);
    final hasPendingShortStay = await _hasPendingShortStay(context, pid);
    final hasApprovedMonthly = await _hasActiveMonthlyRent(context, pid);

    if (!mounted) return;

    if (!supportsShortStay) {
      if (hasPendingMonthly) {
        _showSnackBar(
          "Ne možete rezervisati najamninu jer već imate rezervaciju na čekanju za ovu nekretninu.",
          isError: true,
        );
        return;
      }

      if (hasApprovedMonthly) {
        _showSnackBar(
          "Ne možete rezervisati najamninu jer već imate aktivnu najamninu za ovu nekretninu.",
          isError: true,
        );
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PropertyReservationUniversalScreen(
            property: property,
            type: ReservationType.monthly,
            unavailableDates: const [],
          ),
        ),
      );
      return;
    }

    final monthlyBlocked = hasPendingMonthly || hasApprovedMonthly;
    final shortStayBlocked = hasPendingShortStay;

    if (monthlyBlocked && shortStayBlocked) {
      _showSnackBar(
        "Rezervacije ove nekretnine vec postoje za oba slucaja, koje su ili na čekanju ili aktivne",
        isError: true,
      );
      return;
    }

    String? monthlyDisabledHint;
    if (hasPendingMonthly) {
      monthlyDisabledHint =
          "Rezervacija najamnine na čekanju za ovu nekretninu.";
    } else if (hasApprovedMonthly) {
      monthlyDisabledHint =
          "Imate već aktivnu najamninu za ovu nekretninu.";
    }

    String? shortStayDisabledHint;
    if (hasPendingShortStay) {
      shortStayDisabledHint =
          "Rezervacija kratkog boravka na čekanju za ovu nekretninu.";
    }

    final isMonthly = await _showReservationTypeDialog(
      monthlyEnabled: !monthlyBlocked,
      shortStayEnabled: !shortStayBlocked,
      monthlyDisabledHint: monthlyDisabledHint,
      shortStayDisabledHint: shortStayDisabledHint,
    );

    if (!mounted) return;
    if (isMonthly == null) return;

    final type =
        isMonthly ? ReservationType.monthly : ReservationType.shortStay;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyReservationUniversalScreen(
          property: property,
          type: type,
          unavailableDates: const [],
        ),
      ),
    );
  }

  Future<bool?> _showReservationTypeDialog({
    required bool monthlyEnabled,
    required bool shortStayEnabled,
    String? monthlyDisabledHint,
    String? shortStayDisabledHint,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return RentifyBaseDialog(
          title: "Odabir rezervacije",
          width: 540,
          onClose: () => Navigator.of(dialogContext).pop(null),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Odaberite da li želite rezervisati kao mjesečnu najamninu ili kao kratki boravak.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6E6E6E),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _ReservationChoiceCard(
                      title: "Najamnina",
                      subtitle: monthlyEnabled
                          ? "Rezervacija po mjesecima."
                          : (monthlyDisabledHint ?? "Opcija nije dostupna."),
                      icon: Icons.calendar_month_rounded,
                      enabled: monthlyEnabled,
                      accent: const Color(0xFF5F9F3B),
                      onTap: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ReservationChoiceCard(
                      title: "Kratki boravak",
                      subtitle: shortStayEnabled
                          ? "Rezervacija po danima."
                          : (shortStayDisabledHint ?? "Opcija nije dostupna."),
                      icon: Icons.nightlight_round,
                      enabled: shortStayEnabled,
                      accent: const Color(0xFF1565C0),
                      onTap: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(null),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6E6E6E),
                    side: const BorderSide(color: Color(0xFFBDBDBD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Odustani",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const rentifyGreenDark = Color(0xFF5F9F3B);

    final property = widget.property;

    final title = (property.name ?? "").trim();
    final city = (property.city ?? "").trim();
    final location = (property.location ?? "").trim();
    final details = (property.details ?? "").trim();
    final squares = (property.squareMeters ?? "");

    final monthPrice = property.pricePerMonth;
    final dayPrice = property.pricePerDay;
    final supportsShortStay = property.isRentingPerDay;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Column(
          children: [
            _GalleryHeader(
              propertyId: property.id,
              accent: rentifyGreenDark,
              title: title.isEmpty ? "Nekretnina" : title,
              isFavorite: _isFavorite,
              favoriteLoading: _favoriteLoading,
              onBack: () => Navigator.of(context).pop(),
              onToggleFavorite: _toggleFavorite,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoCard(
                      child: Column(
                        children: [
                          _IconRow(
                            icon: Icons.location_on_rounded,
                            title: city.isEmpty ? "Nepoznat grad" : city,
                            subtitle: location.isEmpty
                                ? "Lokacija nije navedena"
                                : location,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _SmallStat(
                                  title: "Kvadratura",
                                  value: squares == null ? "—" : "$squares m²",
                                  icon: Icons.square_foot_rounded,
                                  accent: rentifyGreenDark,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SmallStat(
                                  title: "Iznajmljivanje",
                                  value: supportsShortStay
                                      ? "Najamnina i kratki boravak"
                                      : "Samo najamnina",
                                  icon: Icons.event_available_rounded,
                                  accent: rentifyGreenDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    _UserMiniScreen(property: property),
                    const SizedBox(height: 12),

                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Cijene",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2F2F2F),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _PriceBox(
                                  title: "Mjesečno",
                                  value: monthPrice == null
                                      ? "—"
                                      : "${monthPrice.toStringAsFixed(0)} KM",
                                  accent: rentifyGreenDark,
                                  icon: Icons.calendar_month_rounded,
                                ),
                              ),
                              if (supportsShortStay) ...[
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _PriceBox(
                                    title: "Po noći",
                                    value: dayPrice == null
                                        ? "—"
                                        : "${dayPrice.toStringAsFixed(0)} KM",
                                    accent: rentifyGreenDark,
                                    icon: Icons.nightlight_round,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if ((property.tags ?? const <String>[]).isNotEmpty) ...[
                      const Text(
                        "Tagovi",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (property.tags ?? const <String>[])
                            .map((t) => _TagChip(text: t))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                    ],

                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Detalji",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2F2F2F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            details.isEmpty ? "Opis nije dostupan." : details,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF7A7A7A),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Imate pitanje o ovoj nekretnini?",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2F2F2F),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Ako vas zanima nešto dodatno, možete poslati pitanje. Odgovor ćete kasnije vidjeti u sekciji sa pitanjima kada admin odgovori.",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF7A7A7A),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _openAskQuestionDialog,
                              icon: const Icon(Icons.question_answer_rounded),
                              label: const Text("Postavi pitanje"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: rentifyGreenDark,
                                side: const BorderSide(
                                  color: Color(0x225F9F3B),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
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
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, -6),
              color: Color(0x14000000),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () async => _handleReservationClick(property),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rentifyGreenDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Rezervacija?",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final payload = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertyAppointmentUniversalScreen(
                        property: property,
                        unavailableAppointments: const [],
                      ),
                    ),
                  );

                  if (!context.mounted) return;

                  if (payload != null) {
                    await ConfirmDialogs.okConfirmation(
                      context,
                      title: "Pregled uživo",
                      message: "Termin je pripremljen.\n\nPodaci:\n$payload",
                    );
                  }
                },
                icon: const Icon(Icons.visibility_rounded, size: 18),
                label: const Text("Pregled uživo"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: rentifyGreenDark,
                  side: const BorderSide(color: Color(0x225F9F3B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------- DIALOG ZA ODABIR TIPA REZERVACIJE ------------------- */

class _ReservationChoiceCard extends StatelessWidget {
  const _ReservationChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = enabled ? const Color(0xFF2F2F2F) : const Color(0xFF9AA0A6);
    final sub = enabled ? const Color(0xFF6E6E6E) : const Color(0xFF9AA0A6);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled ? accent.withOpacity(0.25) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: enabled ? accent : const Color(0xFFBDBDBD)),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: fg,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: sub,
                height: 1.35,
                fontSize: 12.8,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------- DIALOG ZA PITANJE ------------------- */

class _AskQuestionDialog extends StatefulWidget {
  const _AskQuestionDialog({required this.propertyId, required this.userId});

  final int propertyId;
  final int userId;

  @override
  State<_AskQuestionDialog> createState() => _AskQuestionDialogState();
}

class _AskQuestionDialogState extends State<_AskQuestionDialog> {
  final TextEditingController _questionController = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _questionController.text.trim();

    if (content.isEmpty) {
      setState(() {
        _error = "Unesite pitanje.";
      });
      return;
    }

    if (content.length < 5) {
      setState(() {
        _error = "Pitanje je prekratko.";
      });
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      await context.read<QuestionProvider>().insert({
        "userId": widget.userId,
        "propertyId": widget.propertyId,
        "content": content,
        "isAnswered": false,
      });

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "Greška pri slanju pitanja. Pokušajte ponovo.";
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RentifyBaseDialog(
      title: "Postavi pitanje",
      width: 520,
      onClose: () => Navigator.of(context).pop(false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Unesite pitanje vezano za ovu nekretninu. Odgovor ćete moći vidjeti u sekciji sa pitanjima kada admin odgovori.",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6E6E6E),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _questionController,
            minLines: 4,
            maxLines: 6,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: "Npr. Da li su režije uključene u cijenu?",
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              errorText: _error,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF5F9F3B),
                  width: 2,
                ),
              ),
            ),
            onChanged: (_) {
              if (_error != null) {
                setState(() => _error = null);
              }
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _sending
                      ? null
                      : () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6E6E6E),
                    side: const BorderSide(color: Color(0xFFBDBDBD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Odustani",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _sending ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F9F3B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Pošalji",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ------------------- GALERIJA + HEADER ------------------- */

class _GalleryHeader extends StatefulWidget {
  const _GalleryHeader({
    required this.propertyId,
    required this.accent,
    required this.title,
    required this.isFavorite,
    required this.favoriteLoading,
    required this.onBack,
    required this.onToggleFavorite,
  });

  final int? propertyId;
  final Color accent;
  final String title;
  final bool isFavorite;
  final bool favoriteLoading;
  final VoidCallback onBack;
  final VoidCallback onToggleFavorite;

  @override
  State<_GalleryHeader> createState() => _GalleryHeaderState();
}

class _GalleryHeaderState extends State<_GalleryHeader> {
  int _index = 0;

  late final PropertyImageProvider _imgProvider;
  Future<List<PropertyImage>>? _imagesFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _imgProvider = Provider.of<PropertyImageProvider>(context, listen: false);
    _imagesFuture ??= _loadImages(_imgProvider, widget.propertyId);
  }

  @override
  void didUpdateWidget(covariant _GalleryHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.propertyId != widget.propertyId) {
      _index = 0;
      _imagesFuture = _loadImages(_imgProvider, widget.propertyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          FutureBuilder<List<PropertyImage>>(
            future: _imagesFuture,
            builder: (context, snap) {
              final loading = snap.connectionState == ConnectionState.waiting;
              final hasError = snap.hasError;
              final images = snap.data ?? const <PropertyImage>[];

              if (loading) {
                return Container(color: const Color(0xFFE9ECEF));
              }

              if (hasError || images.isEmpty) {
                return Container(
                  color: const Color(0xFFE9ECEF),
                  child: Center(
                    child: Icon(
                      Icons.home_rounded,
                      size: 56,
                      color: widget.accent,
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) {
                      final url = images[i].propertyImg;
                      return Image.network(
                        ImageHelper.httpCheck(url, 'properties'),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE9ECEF),
                          child: Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 42,
                              color: widget.accent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 14,
                    child: _Dots(
                      count: images.length,
                      index: _index,
                      accent: widget.accent,
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Row(
              children: [
                _RoundIconButton(
                  onTap: widget.onBack,
                  icon: Icons.arrow_back_rounded,
                ),
                const Spacer(),
                _RoundIconButton(
                  onTap: widget.favoriteLoading
                      ? () {}
                      : widget.onToggleFavorite,
                  icon: widget.favoriteLoading
                      ? Icons.more_horiz_rounded
                      : (widget.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 38,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x66000000),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<PropertyImage>> _loadImages(
    PropertyImageProvider provider,
    int? propertyId,
  ) async {
    if (propertyId == null) return const <PropertyImage>[];

    final res = await provider.get(
      filter: {
        "PropertyId": propertyId,
        "Page": 0,
        "PageSize": 50,
        "IncludeTotalCount": false,
      },
    );

    final imgs = [...res.items];
    imgs.sort((a, b) => (b.isMain ? 1 : 0).compareTo(a.isMain ? 1 : 0));
    return imgs;
  }
}

class _UserMiniScreen extends StatelessWidget {
  const _UserMiniScreen({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final u = property.user;

    if (u == null) {
      return _InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Podaci o korisniku",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF2F2F2F),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Korisnik nije učitan uz nekretninu (user=null).",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF7A7A7A),
              ),
            ),
          ],
        ),
      );
    }

    String v(String? s) => (s ?? "").trim().isEmpty ? "—" : s!.trim();

    final fullName =
        ("${(u.firstName ?? "").trim()} ${(u.lastName ?? "").trim()}").trim();
    final email = v(u.email);
    final phone = v(u.phoneNumber);

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Podaci o korisniku",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF2F2F2F),
            ),
          ),
          const SizedBox(height: 10),
          _IconRow(
            icon: Icons.person_rounded,
            title: fullName.isEmpty ? "—" : fullName,
            subtitle: "Ime i prezime",
          ),
          const SizedBox(height: 10),
          _IconRow(icon: Icons.email_rounded, title: email, subtitle: "Email"),
          const SizedBox(height: 10),
          _IconRow(
            icon: Icons.phone_rounded,
            title: phone,
            subtitle: "Telefon",
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index, required this.accent});

  final int count;
  final int index;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? Colors.white : const Color(0xAAFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: active ? Border.all(color: accent, width: 2) : null,
          ),
        );
      }),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.onTap, required this.icon});

  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x22FFFFFF)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

/* ------------------- UI building blocks ------------------- */

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 6),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF7A7A7A)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2F2F2F),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7A7A7A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallStat extends StatelessWidget {
  const _SmallStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFF6F7F8),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2F2F2F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  const _PriceBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFF6F7F8),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = text.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: Text(
        t.isEmpty ? "tag" : t,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: Color(0xFF2F2F2F),
        ),
      ),
    );
  }
}
