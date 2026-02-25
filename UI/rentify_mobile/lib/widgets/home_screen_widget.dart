import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/dialogs/property_filter_dialog.dart';
import 'package:rentify_mobile/helper/univerzal_pagging_helper.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/models/property_images.dart';
import 'package:rentify_mobile/models/search_result.dart';
import 'package:rentify_mobile/providers/property_image_provider.dart';
import 'package:rentify_mobile/widgets/swipe_widget.dart';

class BaseBody extends StatelessWidget {
  const BaseBody({
    super.key,
    required this.paging,
    this.fullName,
    this.username,
    this.showWelcome = false,
    required this.sectionTitle,
    required this.sectionSubtitle,
    this.showSearch = false,
    this.searchController,
    this.onSearchChanged,
    this.onClearSearch,
    this.showFilter = false,
    this.onOpenFilter,
  });

  final UniversalPagingProvider<Property> paging;

  // welcome
  final String? fullName;
  final String? username;
  final bool showWelcome;

  // texts
  final String sectionTitle;
  final String sectionSubtitle;

  // search/filter
  final bool showSearch;
  final TextEditingController? searchController;
  final void Function(String value)? onSearchChanged;
  final VoidCallback? onClearSearch;

  final bool showFilter;
  final VoidCallback? onOpenFilter;

  @override
Widget build(BuildContext context) {
  const rentifyGreenDark = Color(0xFF5F9F3B);

  return AnimatedBuilder(
    animation: paging, // <- Sluša promjene (notifyListeners)
    builder: (context, _) {
      return RefreshIndicator(
        onRefresh: paging.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          children: [
            if (showWelcome) ...[
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dobrodošao/la,",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7A7A7A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (fullName ?? "").trim().isEmpty
                          ? "Korisnik"
                          : fullName!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2F2F2F),
                      ),
                    ),
                    if ((username ?? "").trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        username!.trim(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7A7A7A),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Title + subtitle
            Text(
              sectionTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2F2F2F),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sectionSubtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7A7A7A),
              ),
            ),
            const SizedBox(height: 12),

            // Search + Filter (opciono)
            if (showSearch || showFilter) ...[
              Row(
                children: [
                  if (showSearch)
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: "Pretraži nekretnine...",
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: (searchController?.text.isEmpty ?? true)
                              ? null
                              : IconButton(
                                  tooltip: "Očisti",
                                  onPressed: onClearSearch,
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                  if (showSearch && showFilter) const SizedBox(width: 10),

                  if (showFilter)
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: onOpenFilter,
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text("Filter"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rentifyGreenDark,
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
              const SizedBox(height: 12),
            ],

            // List / states
            if (paging.isLoading && paging.items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 18),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (paging.error != null)
              _ErrorBox(text: paging.error!, onRetry: paging.refresh)
            else if (paging.items.isEmpty)
              const _EmptyBox()
            else
              SwipePagedList<Property>(
                provider: paging,
                itemBuilder: (context, item) => _PropertyCard(
                  property: item,
                  accent: rentifyGreenDark,
                ),
              ),

            if (paging.isLoading && paging.items.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      );
    },
  );
}
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({required this.property, required this.accent});

  final Property property;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final title = (property.name ?? "").trim();
    final city = (property.city ?? "").trim();
    final pricePerMonth = property.pricePerMonth ?? 0;
    final pricePerDay = property.pricePerDay ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: open details
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFF2F3F4),
                ),
                child: _PropertyMainImage(
                  propertyId: property.id,
                  accent: accent,
                  size: 70,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? "Nekretnina" : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Color(0xFF2F2F2F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Color(0xFF7A7A7A),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            city.isEmpty ? "Nepoznata lokacija" : city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Color(0xFF7A7A7A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Cijena po mjesecu: ${pricePerMonth.toStringAsFixed(0)} KM",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: accent,
                      ),
                    ),

                    if (pricePerDay != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        "${pricePerDay!.toStringAsFixed(0)} KM / noć",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: accent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B0B0)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: const Row(
        children: [
          Icon(Icons.inbox_rounded, color: Color(0xFF7A7A7A)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Trenutno nema preporuka. Pokušaj drugi filter ili osvježi.",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF7A7A7A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.text, required this.onRetry});

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x22FF0000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Greška pri učitavanju",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF7A7A7A),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onRetry,
              child: const Text("Pokušaj ponovo"),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyMainImage extends StatelessWidget {
  const _PropertyMainImage({
    required this.propertyId,
    required this.accent,
    this.size = 70,
    super.key,
  });

  final int? propertyId;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    // ako nema id, odmah fallback
    if (propertyId == null) {
      return _fallback();
    }

    final imgProvider = Provider.of<PropertyImageProvider>(
      context,
      listen: false,
    );

    return FutureBuilder<List<PropertyImage>>(
      future: _loadMainImage(imgProvider, propertyId!),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _skeleton();
        }

        if (snap.hasError) {
          return _fallback(broken: true);
        }

        final images = snap.data ?? [];
        final main = images.isNotEmpty ? images.first : null;

        final url = main?.propertyImg;
        if (url == null || url.isEmpty) return _fallback();

        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback(broken: true),
          ),
        );
      },
    );
  }

  Future<List<PropertyImage>> _loadMainImage(
    PropertyImageProvider provider,
    int propertyId,
  ) async {
    final res = await provider.get(
      filter: {
        "PropertyId": propertyId,
        "IsMain": true,
        "Page": 0,
        "PageSize": 1,
        "IncludeTotalCount": false,
      },
    );
    return res.items;
  }

  Widget _fallback({bool broken = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFF2F3F4),
      ),
      alignment: Alignment.center,
      child: Icon(
        broken ? Icons.broken_image_rounded : Icons.home_rounded,
        color: accent,
        size: 30,
      ),
    );
  }

  Widget _skeleton() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFE9ECEF),
      ),
    );
  }
}
