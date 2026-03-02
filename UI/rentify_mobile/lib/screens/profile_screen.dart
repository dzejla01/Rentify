import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/helper/date_helper.dart';
import 'package:rentify_mobile/helper/image_helper.dart';
import 'package:rentify_mobile/helper/text_editing_controller_helper.dart';
import 'package:rentify_mobile/models/user.dart';
import 'package:rentify_mobile/providers/image_provider.dart';
import 'package:rentify_mobile/providers/user_provider.dart';
import 'package:rentify_mobile/screens/base_screen.dart';
import 'package:rentify_mobile/utils/session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color rentifyGreenDark = Color(0xFF5F9F3B);

  late final UserProvider _userProvider;

  final _formKey = GlobalKey<FormState>();
  late final Fields fields;

  User? _user;
  bool _loading = true;
  String? _error;

  File? _pickedImage;
  bool _isImageChanged = false;

  // snapshot inicijalnih vrijednosti (za hasChanges)
  Map<String, String> _initial = {};

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();

    fields = Fields.fromNames([
      'firstName',
      'lastName',
      'email',
      'username',
      'phoneNumber',
      'birthDate',
    ]);

    _loadUser();
  }

  @override
  void dispose() {
    fields.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userId = Session.userId;
      if (userId == null) throw Exception("Nema userId u sesiji.");

      final u = await _userProvider.getById(userId);

      // popuni polja
      fields.setText('firstName', u.firstName);
      fields.setText('lastName', u.lastName);
      fields.setText('email', u.email);
      fields.setText('username', u.username);
      fields.setText('phoneNumber', u.phoneNumber ?? '');

      if (u.dateOfBirth != null) {
        fields.setText('birthDate', DateHelper.format(u.dateOfBirth!));
      } else {
        fields.setText('birthDate', '');
      }

      _user = u;
      _pickedImage = null;
      _isImageChanged = false;

      // snapshot za provjeru promjena
      _initial = Map<String, String>.from(fields.values());

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  bool _hasChanges() {
    if (_isImageChanged) return true;

    final now = fields.values();
    for (final k in _initial.keys) {
      if ((now[k] ?? '') != (_initial[k] ?? '')) return true;
    }
    return false;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;

    setState(() {
      _pickedImage = File(x.path);
      _isImageChanged = true;
    });
  }

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final userId = Session.userId;
    if (userId == null) return;

    try {
      // stara slika (da je možemo obrisati nakon uspješnog save-a)
      final oldImg = _user?.userImage;
      String? finalImage = oldImg;

      if (finalImage != null && finalImage.trim().isEmpty) {
        finalImage = null;
      }

      // ✅ upload nove slike (ako je odabrana)
      if (_pickedImage != null) {
        final uploadedFileName = await ImageAppProvider.upload(
          file: _pickedImage!,
          folder: "users",
        );
        finalImage = uploadedFileName;
      }

      await _userProvider.update(userId, {
        'firstName': fields.text("firstName"),
        'lastName': fields.text("lastName"),
        'email': fields.text("email"),
        'username': fields.text("username"),
        'phoneNumber': fields.text("phoneNumber"),
        'dateOfBirth': DateHelper.toIsoFromUi(fields.text("birthDate")),
        'userImage': finalImage,

        // ako API traži ova polja (kao na desktopu)
        'isActive': _user?.isActive ?? true,
        'isVlasnik': _user?.isVlasnik ?? false,
        'createdAt': _user?.createdAt.toIso8601String(),
        'lastLoginAt': _user?.lastLoginAt?.toIso8601String(),
      });

      // ✅ obriši staru sliku (samo ako smo uploadali novu)
      if (_pickedImage != null &&
          oldImg != null &&
          oldImg.trim().isNotEmpty &&
          oldImg != finalImage) {
        await ImageAppProvider.delete(folder: "users", fileName: oldImg);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil je uspješno sačuvan.")),
      );

      await _loadUser(); // refresh + reset initial values
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseMobileScreen(
      title: "Profil",
      NameAndSurname: "${_user?.firstName ?? ""} ${_user?.lastName ?? ""}"
          .trim(),
      userUsername: Session.username ?? "Nepoznato",
      onLogout: () {
        Session.odjava();
        // ti već imaš logout flow – ostavi svoj kako ti je
      },
      child: Container(
        color: const Color(0xFFF6F7FB),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null)
            ? _ErrorState(message: _error!, onRetry: _loadUser)
            : _user == null
            ? _ErrorState(message: "Korisnik nije učitan.", onRetry: _loadUser)
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      children: [
                        _HeaderCard(
                          user: _user!,
                          pickedImage: _pickedImage,
                          onChangeImage: _pickImage,
                        ),
                        const SizedBox(height: 12),
                        _FormCard(
                          formKey: _formKey,
                          fields: fields,
                          onAnyChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),

                  // sticky save
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _hasChanges() ? _save : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rentifyGreenDark,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Sačuvaj",
                          style: TextStyle(fontWeight: FontWeight.w900),
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

/// ---------------- UI ----------------

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.user,
    required this.pickedImage,
    required this.onChangeImage,
  });

  final User user;
  final File? pickedImage;
  final VoidCallback onChangeImage;

  static const Color rentifyGreenDark = Color(0xFF5F9F3B);

  @override
  Widget build(BuildContext context) {
    Widget avatar;

if (pickedImage != null) {
  avatar = Image.file(
    pickedImage!,
    fit: BoxFit.cover,
  );
} else {
  avatar = Image.network(
    ImageHelper.safeUserImageUrl(user.userImage),
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) =>
        ImageHelper.userPlaceholder(user.username),
  );
}

    return Container(
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
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(width: 84, height: 84, child: avatar),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${user.firstName} ${user.lastName}".trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2A1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: onChangeImage,
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: const Text("Promijeni sliku"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: rentifyGreenDark,
                      side: BorderSide(
                        color: rentifyGreenDark.withOpacity(0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.fields,
    required this.onAnyChanged,
  });

  final GlobalKey<FormState> formKey;
  final Fields fields;
  final VoidCallback onAnyChanged;

  static const Color rentifyGreenDark = Color(0xFF5F9F3B);

  String? _req(String? v, String msg) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  String? _email(String? v) {
    final value = (v ?? '').trim();
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(value) ? null : "Neispravan email.";
  }

  String? _username(String? v) {
    final value = (v ?? '').trim();
    final regex = RegExp(r'^[a-zA-Z0-9._-]{3,20}$');
    return regex.hasMatch(value) ? null : "Username 3–20 (slova/brojevi/._-).";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(14),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _field(
                    label: "Ime",
                    controller: fields.controller("firstName"),
                    validator: (v) => _req(v, "Ime je obavezno."),
                    onChanged: (_) => onAnyChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    label: "Prezime",
                    controller: fields.controller("lastName"),
                    validator: (v) => _req(v, "Prezime je obavezno."),
                    onChanged: (_) => onAnyChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(
                    label: "Email",
                    controller: fields.controller("email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: _email,
                    onChanged: (_) => onAnyChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    label: "Username",
                    controller: fields.controller("username"),
                    validator: _username,
                    onChanged: (_) => onAnyChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _dateField(
              context: context,
              label: "Datum rođenja",
              controller: fields.controller("birthDate"),
              onAnyChanged: onAnyChanged,
            ),
            const SizedBox(height: 12),
            _field(
              label: "Telefon",
              controller: fields.controller("phoneNumber"),
              keyboardType: TextInputType.phone,
              validator: (v) => _req(v, "Telefon je obavezan."),
              onChanged: (_) => onAnyChanged(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required VoidCallback onAnyChanged,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: (v) => _req(v, "Datum rođenja je obavezan."),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        suffixIcon: const Icon(
          Icons.calendar_month_outlined,
          color: rentifyGreenDark,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(now.year - 18),
          firstDate: DateTime(1900),
          lastDate: now,
        );
        if (picked == null) return;

        controller.text =
            "${picked.day.toString().padLeft(2, '0')}."
            "${picked.month.toString().padLeft(2, '0')}."
            "${picked.year}.";
        onAnyChanged();
      },
    );
  }

  Widget _field({
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
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Pokušaj ponovo"),
            ),
          ],
        ),
      ),
    );
  }
}
