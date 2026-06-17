import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/helper/exception_read_helper.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/providers/property_provider.dart';
import 'package:rentify_mobile/screens/property_details_screen.dart';

class PropertyMapScreen extends StatefulWidget {
  const PropertyMapScreen({super.key});

  @override
  State<PropertyMapScreen> createState() => _PropertyMapScreenState();
}

class _PropertyMapScreenState extends State<PropertyMapScreen> {
  static const Color _green = Color(0xFF5F9F3B);
  static const LatLng _defaultCenter = LatLng(43.8563, 18.4131); // Sarajevo

  // Koordinate centara gradova — fallback za nekretnine bez GPS koordinata
  static const Map<int, LatLng> _cityCoords = {
    1: LatLng(43.8563, 18.4131), // Sarajevo
    2: LatLng(43.3438, 17.8078), // Mostar
    3: LatLng(44.5382, 18.6735), // Tuzla
    4: LatLng(44.7722, 17.1910), // Banja Luka
    5: LatLng(44.2035, 17.9078), // Zenica
    6: LatLng(44.8167, 15.8667), // Bihać
  };

  List<Property> _properties = [];
  bool _loading = true;
  String? _error;
  Property? _selected;

  final MapController _mapController = MapController();

  LatLng _coordsFor(Property p) {
    if (p.latitude != null && p.longitude != null) {
      return LatLng(p.latitude!, p.longitude!);
    }
    final city = _cityCoords[p.cityId];
    if (city != null) {
      final offsetLat = ((p.id * 7) % 21 - 10) * 0.0008;
      final offsetLng = ((p.id * 11) % 21 - 10) * 0.0008;
      return LatLng(city.latitude + offsetLat, city.longitude + offsetLng);
    }
    return _defaultCenter;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final result = await context.read<PropertyProvider>().get(
        filter: {
          'IsActiveOnApp': true,
          'IncludeCity': true,
          'Page': 0,
          'PageSize': 200,
          'IncludeTotalCount': false,
        },
      );

      if (!mounted) return;
      setState(() {
        _properties = result.items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = extractErrorMessage(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Nekretnine na mapi',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          if (_selected != null)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => setState(() => _selected = null),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Greška pri učitavanju: $_error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        _load();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: _green),
                      child: const Text('Pokušaj ponovo'),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _properties.isNotEmpty
                        ? LatLng(
                            _properties.first.latitude!,
                            _properties.first.longitude!,
                          )
                        : _defaultCenter,
                    initialZoom: 10,
                    onTap: (tap, pos) => setState(() => _selected = null),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.rentify.mobile',
                    ),
                    MarkerLayer(
                      markers: _properties.map((p) {
                        final isSelected = _selected?.id == p.id;
                        final coords = _coordsFor(p);
                        return Marker(
                          point: coords,
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selected = p);
                              _mapController.move(
                                coords,
                                13,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _green
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _green,
                                  width: isSelected ? 0 : 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.home_rounded,
                                color: isSelected ? Colors.white : _green,
                                size: 22,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                if (_properties.isEmpty)
                  const Center(
                    child: Card(
                      margin: EdgeInsets.all(24),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Nema nekretnina sa koordinatama.',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                if (_selected != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: _PropertyCard(
                      property: _selected!,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PropertyDetailsScreen(property: _selected!),
                        ),
                      ),
                      onClose: () => setState(() => _selected = null),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({
    required this.property,
    required this.onTap,
    required this.onClose,
  });

  final Property property;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6E5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.home_rounded,
                color: Color(0xFF5F9F3B),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${property.city?.name ?? ''} • ${property.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7A7A7A),
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    property.isRentingPerDay
                        ? '${property.pricePerDay.toStringAsFixed(0)} KM/noć  •  ${property.pricePerMonth.toStringAsFixed(0)} KM/mj.'
                        : '${property.pricePerMonth.toStringAsFixed(0)} KM/mj.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF5F9F3B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: onClose,
              color: const Color(0xFF9AA0A6),
            ),
          ],
        ),
      ),
    );
  }
}
