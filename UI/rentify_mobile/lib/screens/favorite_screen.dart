import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/models/favorite.dart';
import 'package:rentify_mobile/providers/auth_provider.dart';
import 'package:rentify_mobile/providers/device_token_provider.dart';
import 'package:rentify_mobile/providers/favorite_provider.dart';
import 'package:rentify_mobile/routes/app_routes.dart';
import 'package:rentify_mobile/screens/base_screen.dart';
import 'package:rentify_mobile/screens/property_details_screen.dart';
import 'package:rentify_mobile/utils/session.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late FavoriteProvider _favoriteProvider;

  bool _loading = true;
  String? _error;
  List<Favorite> _items = [];

  @override
  void initState() {
    super.initState();
    _favoriteProvider = context.read<FavoriteProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _favoriteProvider.get(
        filter: {"userId": Session.userId, "includeUser": true, "includePropertyOwner": true},
      );

      if (!mounted) return;

      setState(() {
        _items = result.items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _removeFavorite(Favorite item) async {
    try {
      await _favoriteProvider.delete(item.id);
      await _loadData();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška pri uklanjanju favorita.")),
      );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}.";
  }

  @override
  Widget build(BuildContext context) {
    return BaseMobileScreen(
      title: "Favoriti",
      NameAndSurname: Session.fullName!,
      userUsername: Session.username ?? "Nepoznato",
      userImageAsset: Session.userImage,
      onLogout: () async {
        await Session.odjava(
          deviceTokenProvider: context.read<DeviceTokenProvider>(),
          authProvider: context.read<AuthProvider>(),
        );

        if (!context.mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      },
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text(_error!)),
                ],
              )
            : _items.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 80),
                  const Icon(
                    Icons.favorite_border_rounded,
                    size: 74,
                    color: Color(0xFFA9C64A),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Još nema favorita",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sačuvaj omiljene nekretnine i pregledaj ih kasnije na jednom mjestu.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6E6E6E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/properties");
                    },
                    child: const Text("Pregledaj nekretnine"),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = _items[index];

                  final property = item.property;
                  final user = item.user;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F6E4),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.home_work_rounded,
                                color: Color(0xFF5F9F3B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                property?.name ?? "Nekretnina",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.favorite_rounded,
                              color: Color(0xFF5F9F3B),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (user != null)
                          Text(
                            "Korisnik: ${((user.firstName ?? '') + ' ' + (user.lastName ?? '')).trim()}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6E6E6E),
                            ),
                          ),

                        const SizedBox(height: 6),

                        Text(
                          "Dodano: ${_formatDate(item.createdAt)}",
                          style: const TextStyle(
                            color: Color(0xFF6E6E6E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: item.property != null
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PropertyDetailsScreen(
                                                  property: item.property!,
                                                ),
                                          ),
                                        );
                                      }
                                    : null,
                                child: const Text("Detalji"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _removeFavorite(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5F9F3B),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("Ukloni"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
