import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/helper/univerzal_pagging_helper.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/search_result.dart';
import 'package:rentify_desktop/providers/property_provider.dart';
import 'package:rentify_desktop/routes/app_routes.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/utils/session.dart';
import 'package:rentify_desktop/widgets/pagging_control_widget.dart';

class PropertyScreen extends StatefulWidget {
  const PropertyScreen({super.key});

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  late PropertyProvider _propertyProvider;
  late UniversalPagingProvider<Property> _propertyPaging;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _propertyProvider = Provider.of<PropertyProvider>(context, listen: false);

    _propertyPaging = UniversalPagingProvider<Property>(
      fetcher:
          ({
            required int page,
            required int pageSize,
            String? filter,
            bool includeTotalCount = true,
          }) async {
            final backendFilter = {
              "userId": Session.userId!,
              "page": page,
              "pageSize": pageSize,
              "includeTotalCount": includeTotalCount,
              if (filter != null && filter.isNotEmpty) "FTS": filter,
            };

            final result = await _propertyProvider.get(filter: backendFilter);

            return SearchResult<Property>(
              totalCount: result.totalCount ?? result.items.length,
              items: result.items,
            );
          },
      pageSize: 5,
    );

    _propertyPaging.loadPage();
  }

  Future<void> _onSearchChanged(String value) async {
    await _propertyPaging.goToPage(0);

    await _propertyPaging.loadPage(
      pageNumber: 0,
      filter: value, 
    );
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
              children: [_searchField(), _addNewPropertyButton()],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PaginatedTable<Property>(
                provider: _propertyPaging,
                header: const [
                  SizedBox(width: 220, child: Text('Naziv nekretnine')),
                  SizedBox(width: 240, child: Text('Lokacija')),
                  SizedBox(width: 100, child: Text('Dostupna')),
                  SizedBox(width: 100, child: Text('Aktivna')),
                  SizedBox(width: 120, child: Text('Pregled')),
                ],
                rowBuilder: (property) => [
                  SizedBox(width: 220, child: Text(property.name)),
                  SizedBox(width: 240, child: Text(property.location)),
                  SizedBox(width: 100, child: _checkIcon(property.isAvailable)),
                  SizedBox(
                    width: 100,
                    child: _checkIcon(property.isActiveOnApp),
                  ),
                  SizedBox(
                    width: 120,
                    child: OutlinedButton(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.propertyDetails,
                          arguments: {'property': property, 'isCreate': false},
                        );
                        if (result == true) {
                          await _propertyPaging.refresh();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFA9C64A),
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        'Detalji',
                        style: TextStyle(color: Color(0xFF5F9F3B)),
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

  Widget _searchField() {
    return SizedBox(
      width: 420,
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _onSearchChanged(value),
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

  Widget _addNewPropertyButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          AppRoutes.propertyDetails,
          arguments: {'isCreate': true},
        ).then((refresh) {
          if (refresh == true) {
            _propertyPaging.refresh();
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA9C64A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Dodajte nekretninu'),
    );
  }

  Widget _checkIcon(bool value) {
    return Icon(
      value ? Icons.check_circle : Icons.cancel,
      color: value ? Colors.green : Colors.red,
    );
  }
}
