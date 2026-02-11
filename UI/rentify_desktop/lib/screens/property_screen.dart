import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/property_images.dart';
import 'package:rentify_desktop/providers/property_image_provider.dart';
import 'package:rentify_desktop/providers/property_provider.dart';
import 'package:rentify_desktop/routes/app_routes.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/utils/session.dart';

class PropertyScreen extends StatefulWidget {
  const PropertyScreen({super.key});

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  late PropertyProvider _propertyProvider;

  final TextEditingController _searchController = TextEditingController();
  List<Property> _filtered = [];

  Future<void> loadProperty() async {
    try {
      final properties = await _propertyProvider.get(
        filter: {"userId": Session.userId!},
      );
      setState(() {
        _filtered = properties.items;
      });
    } catch (e) {}
  }

  Future<void> searchProperty(String value) async {
    try {
      final properties = await _propertyProvider.get(
        filter: {"userId": Session.userId!, "name": value},
      );
      setState(() {
        _filtered = properties.items;
      });
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    loadProperty();
  }

  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: "Moje nekretnine",
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _search(),
                _addingNewPropertyButton()
              ],
            ),
            const SizedBox(height: 20),
            _tableHeader(),
            const SizedBox(height: 8),
            Expanded(child: _list()),
          ],
        ),
      ),
    );
  }

  Widget _search() {
    return SizedBox(
      width: 420,
      child: TextField(
        onChanged: (value) async => await searchProperty(value),
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Pretraži nekretninu',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: const Color(0xFFF7F7F7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  Widget _addingNewPropertyButton() {
  return ElevatedButton(
    onPressed: () {
      Navigator.pushNamed(
        context,
        AppRoutes.propertyDetails,
        arguments: {
          'isCreate': true,
        },
      ).then((refresh) {
        if (refresh == true) {
          loadProperty(); 
        }
      });
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFA9C64A), // zelena boja
      foregroundColor: Colors.white, // tekst bijel
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: const Text('Dodajte nekretninu'),
  );
 }


  Widget _tableHeader() {
    return Row(
      children: const [
        SizedBox(width: 220, child: Text('Naziv nekretnine')),
        SizedBox(width: 240, child: Text('Lokacija')),
        SizedBox(width: 100, child: Text('Dostupna')),
        SizedBox(width: 100, child: Text('Aktivna')),
        SizedBox(width: 120, child: Text('Pregled')),
      ],
    );
  }

  Widget _list() {
    return ListView.separated(
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = _filtered[index];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              SizedBox(width: 220, child: Text(p.name)),
              SizedBox(width: 240, child: Text(p.location)),
              SizedBox(width: 100, child: _check(p.isAvailable)),
              SizedBox(width: 100, child: _check(p.isActiveOnApp)),
              SizedBox(
                width: 120,
                child: OutlinedButton(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRoutes.propertyDetails,
                      arguments: {'property': p, 'isCreate': false},
                    );

                    if (result == true) {
                      await loadProperty();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFA9C64A), // Rentify green
                      width: 2,
                    ),
                  ),
                  child: const Text(
                    'Detalji',
                    style: const TextStyle(color: Color(0xFF5F9F3B)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _check(bool value) {
    return Icon(
      value ? Icons.check_circle : Icons.cancel,
      color: value ? Colors.green : Colors.red,
    );
  }
}
