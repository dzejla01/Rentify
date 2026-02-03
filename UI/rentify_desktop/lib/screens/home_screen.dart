import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/dialogs/confirmation_dialogs.dart';
import 'package:rentify_desktop/helper/date_helper.dart';
import 'package:rentify_desktop/helper/image_helper.dart';
import 'package:rentify_desktop/helper/text_editing_controller_helper.dart';
import 'package:rentify_desktop/helper/validation_helper.dart';
import 'package:rentify_desktop/models/user.dart';
import 'package:rentify_desktop/providers/image_provider.dart';
import 'package:rentify_desktop/providers/user_provider.dart';
import 'package:rentify_desktop/routes/app_routes.dart';
import 'package:rentify_desktop/screens/base_dialogs.dart';
import 'package:rentify_desktop/utils/session.dart';
import 'package:path/path.dart' as p;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const Color rentifyGreen = Color(0xFFA9C64A);
  static const Color rentifyGreenDark = Color(0xFF5F9F3B);
  static const Color textDark = Color(0xFF4A4A4A);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool openUserDropdown = false;

  late Fields fields;
  late UserProvider _userProvider;

  User? _loadedUser;
  final _formKey = GlobalKey<FormState>();

  File? _pickedImage;
  bool _isImageChanged = false;
  bool _saved = true;

  void _toggleUserDropdown() {
    setState(() {
      openUserDropdown = !openUserDropdown;
    });
  }

  void _closeUserDropdown() {
    if (!openUserDropdown) return;
    setState(() {
      openUserDropdown = false;
    });
  }

  Future<void> _logout(BuildContext context) async {

   Session.odjava();
 
   if (!context.mounted) return;
 
   Navigator.of(context).pushNamedAndRemoveUntil(
     AppRoutes.login,
     (route) => false,
   );
  }


  Future<void> _confirmExitAndMaybeRevert(BuildContext context) async {
    final bool confirm = await ConfirmDialogs.yesNoConfirmation(
      context,
      question:
          'Ako izađete, sve promjene koje ste napravili biće poništene. '
          'Da li i dalje želite izaći?',
    );

    if (!confirm)
      return;
    else if (confirm) {
      setState(() {
        _pickedImage = null;
      });
    }

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _changeUserImage() async {
    final File? picked = await ImageHelper.openImagePicker();
    if (picked == null) return;

    setState(() {
      _pickedImage = picked; 
      _isImageChanged = true;
      _saved = false;
    });
  }

  Future<void> loadUser() async {
    try {
      final user = await _userProvider.getById(Session.userId!);

      if (user != null) {
        fields.setText('firstName', user.firstName);
        fields.setText('lastName', user.lastName);
        fields.setText('email', user.email);
        fields.setText('username', user.username);
        if(user.dateOfBirth != null) {fields.setText('birthDate', DateHelper.format(user.dateOfBirth!));}
        fields.setText('phoneNumber', user.phoneNumber ?? '');
      }

      setState(() {
        _loadedUser = user;
      });
    } catch (e) {
      debugPrint("Nesto nije uredu ${e}");
    }
  }

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    fields = Fields.fromNames([
      'firstName',
      'lastName',
      'email',
      'username',
      'phoneNumber',
      'birthDate'
    ]);
    loadUser();
  }

  @override
  void dispose() {
    fields.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (openUserDropdown) {
                  setState(() {
                    openUserDropdown = false;
                  });
                }
                return false;
              },
              child: SingleChildScrollView(child: _bodyContent(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 90,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [HomeScreen.rentifyGreenDark, HomeScreen.rentifyGreen],
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/rentify_single_R_white.png',
                width: 46,
                height: 46,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              const Text(
                'Rentify',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          PopupMenuButton<String>(
            tooltip: '',
            offset: const Offset(0, 52),
            onSelected: (value) {
              if (value == 'settings') {
                _showPopup('Postavke');
              } else if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: const [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Postavke',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout_rounded, size: 20, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      'Odjava',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final color = isDanger ? Colors.red.shade700 : const Color(0xFF4A4A4A);

    return InkWell(
      onTap: onTap,
      hoverColor: Colors.black.withOpacity(0.04),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPopup(String title) async {
    await loadUser();
    if (!mounted) return;

    _pickedImage = null;
    _isImageChanged = false;
    _saved = false;

    final initial = Map<String, String>.from(fields.values());

    bool hasChanges() {
      if (_isImageChanged) {
        return true;
      }

      final now = fields.values();
      for (final k in initial.keys) {
        if ((now[k] ?? '') != (initial[k] ?? '')) return true;
      }
      return false;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return RentifyBaseDialog(
            title: 'Postavke',
            width: 640,
            height: 650,
            onClose: () async {
              if (_isImageChanged || hasChanges()) {
                await _confirmExitAndMaybeRevert(context);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: settingsProfile(
              fields: fields,
              user: _loadedUser,
              onSave: () async {
                final ok = _formKey.currentState?.validate() ?? false;
                if (!ok) return;

                String finalImage = _loadedUser!.userImage;

                if (_pickedImage != null) {
                  final uploadedFileName = await ImageAppProvider.upload(
                    file: _pickedImage!,
                    folder: "users",
                  );
                  finalImage = uploadedFileName;
                }

                await _userProvider.update(Session.userId!, {
                  'firstName': fields.text("firstName"),
                  'lastName': fields.text("lastName"),
                  'email': fields.text("email"),
                  'username': fields.text("username"),
                  'phoneNumber': fields.text("phoneNumber"),
                  'dateOfBirth': DateHelper.toIsoFromUi(fields.text("birthDate")),
                  'userImage': finalImage,
                  'isActive': _loadedUser!.isActive,
                  'isVlasnik': _loadedUser!.isVlasnik,
                  'createdAt': _loadedUser!.createdAt.toIso8601String(),
                  'lastLoginAt': _loadedUser!.lastLoginAt?.toIso8601String(),
                });

                // (opcionalno) obriši staru sliku tek sad, nakon uspjeha
                if (_pickedImage != null) {
                  final oldImg = _loadedUser!.userImage;
                  if (oldImg.isNotEmpty &&
                      !ImageHelper.isHttp(oldImg) &&
                      oldImg != finalImage) {
                    await ImageAppProvider.delete(
                      folder: "users",
                      fileName: oldImg,
                    );
                  }
                }

                _saved = true;
                _pickedImage = null;

                await loadUser();
                if (context.mounted) Navigator.of(context).pop();
              },

              onChangeImage: _changeUserImage,
              onAnyChanged: () => setStateDialog(() {}),
              isSaveEnabled: hasChanges(),
            ),
          );
        },
      ),
    );
  }

  Widget settingsProfile({
    required Fields fields,
    required User? user,
    required VoidCallback onSave,
    required Future<void> Function() onChangeImage,
    required VoidCallback onAnyChanged,
    required bool isSaveEnabled,
  }) {
    if (user == null) {
      return const Center(child: Text('Korisnik nije učitan.'));
    }
    const saveColor = Color(0xFF5F9F3B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // HEADER
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 160,
                  height: 160,
                  color: const Color(0x11000000),
                  child: _pickedImage != null
                      ? Image.file(_pickedImage!, fit: BoxFit.cover)
                      : Image.network(
                          ImageHelper.httpCheck(user.userImage),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              user.username.isNotEmpty
                                  ? user.username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4A4A4A),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3F3F3F),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B6B6B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  await onChangeImage();
                  onAnyChanged();
                },
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Promijeni sliku'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // FORM
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled, // poruke tek na Save
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _settingsFieldSimple(
                        label: 'Ime',
                        controller: fields.controller('firstName'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ime je obavezno.'
                            : null,
                        onChanged: (_) => onAnyChanged(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _settingsFieldSimple(
                        label: 'Prezime',
                        controller: fields.controller('lastName'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Prezime je obavezno.'
                            : null,
                        onChanged: (_) => onAnyChanged(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _settingsFieldSimple(
                        label: 'Email',
                        controller: fields.controller('email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: ValidationHelper.emailValidator,
                        onChanged: (_) => onAnyChanged(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _settingsFieldSimple(
                        label: 'Username',
                        controller: fields.controller('username'),
                        validator: ValidationHelper.usernameValidator,
                        onChanged: (_) => onAnyChanged(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _datePickerField(
                  context: context,
                  label: 'Datum rođenja',
                  controller: fields.controller('birthDate'),
                  onAnyChanged: onAnyChanged,
                ),

                const SizedBox(height: 12),
                _settingsFieldSimple(
                  label: 'Telefon',
                  controller: fields.controller('phoneNumber'),
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      ValidationHelper.phoneValidator(v, required: true),
                  onChanged: (_) => onAnyChanged(),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // ACTIONS
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: isSaveEnabled
                  ? () {
                      final ok = _formKey.currentState?.validate() ?? false;
                      if (!ok) return;

                      onSave();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: saveColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sačuvaj',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _datePickerField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required VoidCallback onAnyChanged,
    DateTime? initialDate,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true, // 👈 nema tipkanja
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        suffixIcon: const Icon(Icons.calendar_month_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) =>
          v == null || v.isEmpty ? 'Datum rođenja je obavezan.' : null,
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime(now.year - 18), // default 18+
          firstDate: DateTime(1900),
          lastDate: now,
        );

        if (picked == null) return;

        controller.text =
            "${picked.day.toString().padLeft(2, '0')}. "
            "${picked.month.toString().padLeft(2, '0')}. "
            "${picked.year}.";

        onAnyChanged(); // refresh + enable save
      },
    );
  }

  Widget _settingsFieldSimple({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged, // ✅ samo refresh
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _bodyContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 26, 30, 30),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            'Dobrodošli u Rentify',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w600,
              color: HomeScreen.textDark,
            ),
          ),
          const SizedBox(height: 26),
          _cardsGrid(context),
        ],
      ),
    );
  }

  Widget _cardsGrid(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Wrap(
          spacing: 26,
          runSpacing: 26,
          children: [
            _dashboardCard(
              icon: Icons.home_work_outlined,
              title: 'Moje nekretnine',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.properties);
              },
            ),
            _dashboardCard(
              icon: Icons.calendar_month_outlined,
              title: 'Rezervacije',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.reservations);
              },
            ),
            _dashboardCard(
              icon: Icons.attach_money,
              title: 'Zahtjevi plaćanja',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.payments);
              },
            ),
            _dashboardCard(
              icon: Icons.show_chart,
              title: 'Izvještaji',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.reports);
              },
            ),
            _dashboardCard(
              icon: Icons.import_contacts_rounded,
              title: 'Recenzije',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.reviews);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 560,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEDEDED), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 22,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: HomeScreen.rentifyGreen.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: HomeScreen.rentifyGreenDark,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: HomeScreen.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeScreen.rentifyGreenDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Pregledaj',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
