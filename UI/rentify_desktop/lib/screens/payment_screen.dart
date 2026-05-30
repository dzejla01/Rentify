import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/models/user.dart';
import 'package:rentify_desktop/providers/reservation_provider.dart';
import 'package:rentify_desktop/providers/user_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/screens/payment_user.dart';
import 'package:rentify_desktop/utils/session.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final ReservationProvider _reservationProvider;
  late final UserProvider _userProvider;

  final TextEditingController _searchCtrl = TextEditingController();

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];

  bool _isLoadingUsers = true;
  String? _loadError;

  int _page = 0;
  final int _pageSize = 5;

  @override
  void initState() {
    super.initState();

    _reservationProvider = Provider.of<ReservationProvider>(
      context,
      listen: false,
    );
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    _searchCtrl.addListener(_applySearchAndResetPage);

    _loadUsers();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applySearchAndResetPage);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _loadError = null;
    });

    try {
      final users = await _loadAvailableUsers();

      if (!mounted) return;

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _page = 0;
        _isLoadingUsers = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingUsers = false;
        _loadError = "Greška pri učitavanju korisnika.";
      });
    }
  }

  Future<List<User>> _loadAvailableUsers() async {
    final ownerId = Session.userId;
    if (ownerId == null) {
      throw Exception("Korisnik nije prijavljen.");
    }

    final reservationsResult = await _reservationProvider.get(
      filter: {
        "ownerId": ownerId,
        "retrieveAll": true,
        "page": 0,
        "pageSize": 1000,
        "includeTotalCount": false,
        "includeUser": true,
      },
    );

    final relevantReservations = reservationsResult.items
        .where((r) => r.status?.name != "Odbijeno")
        .toList();

    final uniqueUserIds = relevantReservations.map((r) => r.userId).toSet();

    final List<User> users = [];
    for (final userId in uniqueUserIds) {
      User? reservationUser;
      for (final reservation in relevantReservations) {
        if (reservation.userId == userId && reservation.user != null) {
          reservationUser = reservation.user;
          break;
        }
      }

      final user = reservationUser ?? await _userProvider.getById(userId);
      users.add(user);
    }

    users.sort((a, b) {
      final fullA = "${a.firstName} ${a.lastName}".toLowerCase();
      final fullB = "${b.firstName} ${b.lastName}".toLowerCase();
      return fullA.compareTo(fullB);
    });

    return users;
  }

  void _applySearchAndResetPage() {
    final query = _searchCtrl.text.trim().toLowerCase();

    final filtered = _allUsers.where((user) {
      final fullName = "${user.firstName} ${user.lastName}".toLowerCase();
      return fullName.contains(query);
    }).toList();

    setState(() {
      _filteredUsers = filtered;
      _page = 0;
    });
  }

  int get _totalPages {
    if (_filteredUsers.isEmpty) return 1;
    return (_filteredUsers.length / _pageSize).ceil();
  }

  List<User> get _pagedUsers {
    final start = _page * _pageSize;
    if (start >= _filteredUsers.length) return [];

    final end = (start + _pageSize) > _filteredUsers.length
        ? _filteredUsers.length
        : (start + _pageSize);

    return _filteredUsers.sublist(start, end);
  }

  bool get _hasPreviousPage => _page > 0;
  bool get _hasNextPage => _page < _totalPages - 1;

  void _goToPreviousPage() {
    if (!_hasPreviousPage) return;
    setState(() => _page--);
  }

  void _goToNextPage() {
    if (!_hasNextPage) return;
    setState(() => _page++);
  }

  Widget _buildUserCard(User user) {
    final initials =
        "${user.firstName.isNotEmpty ? user.firstName[0] : ""}"
        "${user.lastName.isNotEmpty ? user.lastName[0] : ""}";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF5F9F3B),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${user.firstName} ${user.lastName}",
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Pregled nekretnina korisnika",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentUserScreen(user: user),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5F9F3B),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.home_rounded, size: 18),
              label: const Text(
                "Nekretnine",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: _hasPreviousPage ? _goToPreviousPage : null,
          icon: const Icon(Icons.arrow_back),
        ),
        Text("${_page + 1} / $_totalPages"),
        IconButton(
          onPressed: _hasNextPage ? _goToNextPage : null,
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: "Zahtjevi plaćanja",
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                text: "Izaberi korisnika",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
                children: [
                  TextSpan(
                    text: " *",
                    style: TextStyle(
                      color: Color(0xFF5F9F3B),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 420,
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: "Pretraga korisnika...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                          },
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoadingUsers
                  ? const Center(child: CircularProgressIndicator())
                  : _loadError != null
                      ? Center(
                          child: Text(
                            _loadError!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : _filteredUsers.isEmpty
                          ? const Center(
                              child: Text("Nema dostupnih korisnika."),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _pagedUsers.length,
                                    itemBuilder: (context, index) {
                                      final user = _pagedUsers[index];
                                      return _buildUserCard(user);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildPagingControls(),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
