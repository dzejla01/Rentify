import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/dialogs/confirmation_dialogs.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/models/property_images.dart';
import 'package:rentify_mobile/providers/property_image_provider.dart';
import 'package:rentify_mobile/screens/property_reservation_screen.dart';

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({super.key, required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    const rentifyGreenDark = Color(0xFF5F9F3B);

    final title = (property.name ?? "").trim();
    final city = (property.city ?? "").trim();
    final location = (property.location ?? "").trim();
    final details = (property.details ?? "").trim();
    final squares = (property.numberOfsquares ?? "").trim();

    final monthPrice = property.pricePerMonth;
    final dayPrice = property.pricePerDay;

    final isAvailable = property.isAvailable ?? false;
    final isDayRent = property.isRentingPerDay ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER + GALERIJA
            _GalleryHeader(
              propertyId: property.id,
              accent: rentifyGreenDark,
              title: title.isEmpty ? "Nekretnina" : title,
            ),

            // BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + badges
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title.isEmpty ? "Nekretnina" : title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2F2F2F),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _Badge(
                          text: isAvailable ? "Dostupno" : "Nedostupno",
                          bg: isAvailable
                              ? const Color(0xFFE7F6EA)
                              : const Color(0xFFFFE8E8),
                          fg: isAvailable
                              ? const Color(0xFF1B7A2B)
                              : const Color(0xFFB00020),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Location card
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
                                  value: squares.isEmpty ? "—" : "$squares m²",
                                  icon: Icons.square_foot_rounded,
                                  accent: rentifyGreenDark,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SmallStat(
                                  title: "Iznajmljivanje",
                                  value: isDayRent ? "Po danu" : "Po mjesecu",
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

                    // Prices
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tags
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

                    // Details / description
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // BOTTOM BAR (CTA)
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
                  onPressed: !isAvailable
                      ? null
                      : () async {
                          final isMonthly =
                              await ConfirmDialogs.badGoodConfirmation(
                                context,
                                title: "Odabir rezervacije",
                                question:
                                    "Da li želite rezervisati mjesečnu kiriju ili kratki boravak?",
                                goodText: "Mjesečna kirija",
                                badText: "Kratki boravak",
                                barrierDismissible: true,
                              );

                          if (!context.mounted) return;

                          final type = isMonthly
                              ? ReservationType.monthly
                              : ReservationType.shortStay;

                          final payload = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PropertyReservationUniversalScreen(
                                    property: property,
                                    type: type,
                                    unavailableDates: const [],
                                  ),
                            ),
                          );

                          if (!context.mounted) return;

                          // Ako je korisnik kliknuo "Nastavi"
                          if (payload != null) {
                            ConfirmDialogs.okConfirmation(
                              context,
                              title: "Rezervacija",
                              message:
                                  "Rezervacija je pripremljena.\n\nPodaci:\n$payload",
                            );

                            // 🔥 OVDJE KASNIJE IDE:
                            // await _reservationProvider.insert(payload);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rentifyGreenDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Rezerviši",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat_rounded, size: 18),
                label: const Text("Kontakt"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F2F2F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
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
  });

  final int? propertyId;
  final Color accent;
  final String title;

  @override
  State<_GalleryHeader> createState() => _GalleryHeaderState();
}

class _GalleryHeaderState extends State<_GalleryHeader> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final imgProvider = Provider.of<PropertyImageProvider>(
      context,
      listen: false,
    );

    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          // Gallery
          FutureBuilder<List<PropertyImage>>(
            future: _loadImages(imgProvider, widget.propertyId),
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
                        url ?? "",
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

                  // indicators
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

          // Top gradient overlay
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xAA000000), Color(0x00000000)],
                ),
              ),
            ),
          ),

          // Back + title
          Positioned(
            left: 12,
            top: 10,
            right: 12,
            child: Row(
              children: [
                _RoundIconButton(
                  onTap: () => Navigator.pop(context),
                  icon: Icons.arrow_back_rounded,
                ),
                const SizedBox(width: 10),
                Expanded(
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
              ],
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

    // ako želiš main sliku prvu:
    final imgs = [...res.items];
    imgs.sort((a, b) => (b.isMain ? 1 : 0).compareTo(a.isMain ? 1 : 0));
    return imgs;
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
                  maxLines: 1,
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

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: fg),
      ),
    );
  }
}
