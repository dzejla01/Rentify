import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/dialogs/confirmation_dialogs.dart';
import 'package:rentify_desktop/helper/snackBar_helper.dart';
import 'package:rentify_desktop/models/building_type.dart';
import 'package:rentify_desktop/models/city.dart';
import 'package:rentify_desktop/models/status.dart';
import 'package:rentify_desktop/providers/base_provider.dart';
import 'package:rentify_desktop/providers/building_type_provider.dart';
import 'package:rentify_desktop/providers/city_provider.dart';
import 'package:rentify_desktop/providers/status_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';

class ReferenceDataScreen extends StatelessWidget {
  const ReferenceDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: "Sifarnici",
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: const [
            _TabsHeader(),
            Expanded(
              child: TabBarView(
                children: [
                  _ReferenceTab<City>(
                    title: "Gradovi",
                    providerSelector: _cityProvider,
                  ),
                  _ReferenceTab<BuildingType>(
                    title: "Tipovi nekretnina",
                    providerSelector: _buildingTypeProvider,
                  ),
                  _ReferenceTab<Status>(
                    title: "Statusi",
                    providerSelector: _statusProvider,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

CityProvider _cityProvider(BuildContext context) =>
    context.read<CityProvider>();

BuildingTypeProvider _buildingTypeProvider(BuildContext context) =>
    context.read<BuildingTypeProvider>();

StatusProvider _statusProvider(BuildContext context) =>
    context.read<StatusProvider>();

class _TabsHeader extends StatelessWidget {
  const _TabsHeader();

  static const Color _green = Color(0xFF5F9F3B);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: TabBar(
          isScrollable: true,
          labelColor: _green,
          unselectedLabelColor: Color(0xFF6B7280),
          indicatorColor: _green,
          indicatorWeight: 3,
          tabs: [
            Tab(icon: Icon(Icons.location_city_outlined), text: "Gradovi"),
            Tab(icon: Icon(Icons.apartment_rounded), text: "Tipovi"),
            Tab(icon: Icon(Icons.fact_check_outlined), text: "Statusi"),
          ],
        ),
      ),
    );
  }
}

class _ReferenceTab<T> extends StatefulWidget {
  const _ReferenceTab({
    required this.title,
    required this.providerSelector,
  });

  final String title;
  final BaseProvider<T> Function(BuildContext context) providerSelector;

  @override
  State<_ReferenceTab<T>> createState() => _ReferenceTabState<T>();
}

class _ReferenceTabState<T> extends State<_ReferenceTab<T>> {
  static const Color _green = Color(0xFF5F9F3B);
  static const Color _greenSoft = Color(0xFFEAF6E5);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _text = Color(0xFF374151);

  final TextEditingController _searchController = TextEditingController();
  List<T> _items = [];
  bool _loading = true;

  BaseProvider<T> get _provider => widget.providerSelector(context);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final result = await _provider.get(
        filter: {
          "RetrieveAll": true,
          if (_searchController.text.trim().isNotEmpty)
            "FTS": _searchController.text.trim(),
        },
      );

      if (!mounted) return;
      setState(() {
        _items = result.items;
      });
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, "$e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm([T? item]) async {
    final currentName = item == null ? "" : _nameOf(item);
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(item == null ? "Dodaj ${widget.title.toLowerCase()}" : "Uredi zapis"),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                autofocus: true,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: "Naziv",
                  prefixIcon: const Icon(Icons.edit_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Naziv je obavezan.";
                  }
                  return null;
                },
                onFieldSubmitted: (_) async {
                  if (formKey.currentState?.validate() != true) return;
                  Navigator.of(dialogContext).pop(true);
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Odustani"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text("Sacuvaj"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (saved != true) {
      controller.dispose();
      return;
    }

    final name = controller.text.trim();
    controller.dispose();

    try {
      if (item == null) {
        await _provider.insert({"name": name});
        if (!mounted) return;
        SnackbarHelper.showSuccess(context, "Zapis je dodan.");
      } else {
        await _provider.update(_idOf(item), {"name": name});
        if (!mounted) return;
        SnackbarHelper.showUpdate(context, "Zapis je sacuvan.");
      }

      await _load();
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, "$e");
    }
  }

  Future<void> _delete(T item) async {
    final confirm = await ConfirmDialogs.yesNoConfirmation(
      context,
      question: "Da li zelite obrisati zapis '${_nameOf(item)}'?",
    );

    if (!confirm) return;

    try {
      await _provider.delete(_idOf(item));
      if (!mounted) return;
      SnackbarHelper.showDelete(context, "Zapis je obrisan.");
      await _load();
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, "$e");
    }
  }

  int _idOf(T item) {
    final dynamic value = item;
    return value.id as int;
  }

  String _nameOf(T item) {
    final dynamic value = item;
    return value.name as String;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: "Pretraga",
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                tooltip: "Osvjezi",
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_rounded),
                label: const Text("Dodaj"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? const Center(
                          child: Text(
                            "Nema zapisa za prikaz.",
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: _border),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor: _greenSoft,
                                foregroundColor: _green,
                                child: Text(
                                  _idOf(item).toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              title: Text(
                                _nameOf(item),
                                style: const TextStyle(
                                  color: _text,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              trailing: Wrap(
                                spacing: 6,
                                children: [
                                  IconButton(
                                    tooltip: "Uredi",
                                    onPressed: () => _openForm(item),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: "Obrisi",
                                    onPressed: () => _delete(item),
                                    icon: const Icon(Icons.delete_outline),
                                    color: Colors.red.shade700,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
