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
              // 1️⃣ Izbor korisnika
              const Text("Izaberi korisnika:*"),
              const SizedBox(height: 5),
              // Zamijeni trenutni DropdownButtonFormField<User> ovim
              _isLoadingUsers
                  ? const CircularProgressIndicator()
                  : Column(
                      children: _users.map((user) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // elipsa
                          ),
                          color: Colors.grey[200],
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${user.firstName} ${user.lastName}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (user == null) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PaymentUserScreen(user: user),
                                      ),
                                    );
                                  },
                                  child: const Text("Pogledaj nekretnine"),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

              // const SizedBox(height: 20),

              // // 2️⃣ Mjesecno plaćanje
              // if (_selectedUser != null) ...[
              //   Row(
              //     children: [
              //       const Text("Da li se radi o uplati mjesecne kirije?"),
              //       Container(
              //         width: 120,
              //         child: RadioListTile<bool>(
              //           title: const Text("Da"),
              //           value: true,
              //           groupValue: _isMonthly,
              //           onChanged: _userAndMonthlyDisabled
              //               ? null
              //               : (val) {
              //                   setState(() {
              //                     _isMonthly = val;
              //                     _userAndMonthlyDisabled = true;
              //                   });
              //                   _updateAvailableProperties();
              //                 },
              //         ),
              //       ),
              //       Container(
              //         width: 120,
              //         child: RadioListTile<bool>(
              //           title: const Text("Ne"),
              //           value: false,
              //           groupValue: _isMonthly,
              //           onChanged: _userAndMonthlyDisabled
              //               ? null
              //               : (val) {
              //                   setState(() {
              //                     _isMonthly = val;
              //                     _userAndMonthlyDisabled = true;
              //                   });
              //                   _updateAvailableProperties();
              //                 },
              //         ),
              //       ),
              //     ],
              //   ),
              // ],

              // // 3️⃣ Izbor nekretnine (filtrirano po isMonthly)
              // if (_userAndMonthlyDisabled &&
              //     _filteredProperties.isNotEmpty) ...[
              //   const SizedBox(height: 20),
              //   const Text("Izaberi nekretninu:*"),
              //   const SizedBox(height: 5),
              //   DropdownButtonFormField<String>(
              //     value: _selectedPropertyId,
              //     decoration: InputDecoration(
              //       border: const OutlineInputBorder(),
              //       errorText: _errors["property"],
              //       isDense: true,
              //       contentPadding: const EdgeInsets.symmetric(
              //         horizontal: 10,
              //         vertical: 12,
              //       ),
              //     ),
              //     items: _filteredProperties
              //         .map(
              //           (p) => DropdownMenuItem(
              //             value: p.id.toString(),
              //             child: Text(p.name),
              //           ),
              //         )
              //         .toList(),
              //     onChanged: (value) {
              //       setState(() {
              //         _selectedPropertyId = value;
              //         _propertySelected = true;
              //         _errors.remove("property");
              //       });
              //     },
              //   ),
              // ],

              // const SizedBox(height: 5),
              // if (_propertySelected) ...[
              //   const SizedBox(height: 20),
              //   const Text("Naslov:*"),
              //   const SizedBox(height: 5),
              //   TextField(
              //     controller: _fields.controller("title"),
              //     decoration: InputDecoration(
              //       border: const OutlineInputBorder(),
              //       errorText: _errors["title"],
              //       isDense: true,
              //       contentPadding: const EdgeInsets.symmetric(
              //         horizontal: 10,
              //         vertical: 12,
              //       ),
              //     ),
              //   ),
              //   const SizedBox(height: 20),
              //   const Text("Iznos:*"),
              //   const SizedBox(height: 5),
              //   TextField(
              //     controller: _fields.controller("amount"),
              //     keyboardType: TextInputType.number,
              //     decoration: InputDecoration(
              //       border: const OutlineInputBorder(),
              //       errorText: _errors["amount"],
              //       isDense: true,
              //       contentPadding: const EdgeInsets.symmetric(
              //         horizontal: 10,
              //         vertical: 12,
              //       ),
              //     ),
              //   ),
              //   const SizedBox(height: 20),
              //   const Text("Komentar:*"),
              //   const SizedBox(height: 5),
              //   TextField(
              //     controller: _fields.controller("comment"),
              //     maxLines: 5,
              //     decoration: InputDecoration(
              //       border: const OutlineInputBorder(),
              //       errorText: _errors["comment"],
              //       isDense: true,
              //       contentPadding: const EdgeInsets.all(10),
              //     ),
              //   ),
              // ],

              // const SizedBox(height: 30),

              // // 7️⃣ Submit button
              // if (_propertySelected)
              //   Align(
              //     alignment: Alignment.centerRight,
              //     child: ElevatedButton(
              //       onPressed: _submit,
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.red,
              //         foregroundColor: Colors.white,
              //       ),
              //       child: const Text("Pošalji zahtjev"),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
