import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/helper/text_editing_controller_helper.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/reservation.dart';
import 'package:rentify_desktop/models/user.dart';
import 'package:rentify_desktop/providers/property_provider.dart';
import 'package:rentify_desktop/providers/reservation_provider.dart';
import 'package:rentify_desktop/providers/user_provider.dart';
import 'package:rentify_desktop/screens/base_screen.dart';
import 'package:rentify_desktop/screens/payment_user.dart';
import 'package:rentify_desktop/utils/session.dart';
import 'package:rentify_desktop/validation/validation_model/validation_field_rule.dart';
import 'package:rentify_desktop/validation/validation_model/validation_rules.dart';
import 'package:rentify_desktop/validation/validation_use/universal_error_removal.dart';
import 'package:rentify_desktop/validation/validation_use/universal_validator.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late PropertyProvider _propertyProvider;
  late ReservationProvider _reservationProvider;
  late UserProvider _userProvider;
  final _fields = Fields.fromNames(["title", "amount", "comment"]);

  String? _selectedPropertyId;
  Map<String, String?> _errors = {};

  List<Property> _properties = [];
  bool _isLoadingProperties = true;

  List<User> _users = [];
  User? _selectedUser;
  bool _isLoadingUsers = true;
  bool? _isMonthly;

  bool _userAndMonthlyDisabled = false;
  bool _propertySelected = false;
  List<Property> _filteredProperties = [];

  @override
  void initState() {
    super.initState();

    _fields.map.forEach((name, ctrl) {
      ErrorAutoRemoval.removeErrorOnTextField(
        field: name,
        fieldErrors: _errors,
        controller: ctrl,
        setState: () => setState(() {}),
      );
    });

    _propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    _reservationProvider = Provider.of<ReservationProvider>(
      context,
      listen: false,
    );
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    _loadUsers();
    _loadProperties();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);

    try {
      final users = await loadAvailableUsers();
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() => _isLoadingUsers = false);
      debugPrint("Greška pri učitavanju korisnika: $e");
    }
  }

  Future<List<User>> loadAvailableUsers() async {
    final reservationsResult = await _reservationProvider.get(
      filter: {"retrieveAll": true},
    );

    final approvedReservations = reservationsResult.items
        .where((r) => r.isApproved == true)
        .fold<Map<int, Reservation>>({}, (map, r) {
          map.putIfAbsent(r.userId, () => r);
          return map;
        })
        .values
        .toList();

    final propertiesResult = await _propertyProvider.get(
      filter: {"userId": Session.userId},
    );

    final ownerPropertyIds = propertiesResult.items.map((p) => p.id).toSet();

    final filteredReservations = approvedReservations
        .where((r) => ownerPropertyIds.contains(r.propertyId))
        .toList();

    final List<User> users = [];
    for (var r in filteredReservations) {
      final user = await UserProvider().getById(r.userId);
      users.add(user);
    }
    return users;
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoadingProperties = true;
    });

    try {
      final result = await _propertyProvider.get(
        filter: {"userId": Session.userId},
      );

      setState(() {
        _properties = result.items;
        _isLoadingProperties = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProperties = false;
      });
      debugPrint("Greška pri učitavanju nekretnina: $e");
    }
  }

  void _submit() {
    final rules = <FieldRule>[
      Rules.requiredText("title", _fields.text("title"), "Naslov je obavezan."),
      Rules.minLength(
        "title",
        _fields.text("title"),
        3,
        "Naslov mora imati barem 3 karaktera.",
      ),
      Rules.requiredText(
        "amount",
        _fields.text("amount"),
        "Iznos je obavezan.",
      ),
      Rules.positiveNumber(
        "amount",
        _fields.text("amount"),
        "Iznos mora biti pozitivan broj.",
      ),
      FieldRule(
        "user",
        () => _selectedUser == null ? "Morate odabrati korisnika." : null,
      ),

      FieldRule(
        "property",
        () =>
            _selectedPropertyId == null ? "Morate odabrati nekretninu." : null,
      ),
      Rules.requiredText(
        "comment",
        _fields.text("comment"),
        "Komentar je obavezan.",
      ),
    ];

    final isValid = ValidationEngine.validate(rules, (field, message) {
      _errors[field] = message;
      setState(() {});
    });

    if (!isValid) return;

    debugPrint("VALIDNO 🔥");
    debugPrint(_fields.values().toString());
    debugPrint("Property: $_selectedPropertyId");
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RentifyBasePage(
      title: "Zahtjevi plaćanja",
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
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
                        color: Color(0xFF5F9F3B), // Rentify green
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              _isLoadingUsers
                  ? const CircularProgressIndicator()
                  : Column(
                      children: _users.map((user) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.05),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 18,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                // 👤 Avatar circle
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF5F9F3B),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${user.firstName[0]}${user.lastName[0]}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // 📄 User info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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

                                // 🔘 Action button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PaymentUserScreen(user: user),
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
                                  icon: const Icon(
                                    Icons.home_rounded,
                                    size: 18,
                                  ),
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
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
