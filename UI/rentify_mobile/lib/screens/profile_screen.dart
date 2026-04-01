import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/helper/date_helper.dart';
import 'package:rentify_mobile/helper/image_helper.dart';
import 'package:rentify_mobile/helper/text_editing_controller_helper.dart';
import 'package:rentify_mobile/models/user.dart';
import 'package:rentify_mobile/providers/auth_provider.dart';
import 'package:rentify_mobile/providers/device_token_provider.dart';
import 'package:rentify_mobile/providers/image_provider.dart';
import 'package:rentify_mobile/providers/user_provider.dart';
import 'package:rentify_mobile/routes/app_routes.dart';
import 'package:rentify_mobile/screens/base_screen.dart';
import 'package:rentify_mobile/utils/session.dart';
import 'package:rentify_mobile/validation/validation_model/validation_rules.dart';
import 'package:rentify_mobile/validation/validation_use/universal_error_removal.dart';
import 'package:rentify_mobile/validation/validation_use/universal_validator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color rentifyGreenDark = Color(0xFF5F9F3B);

  late final UserProvider _userProvider;
  late final Fields fields;

  User? _user;
  bool _loading = true;
  String? _error;

  File? _pickedImage;
  bool _isImageChanged = false;

  Map<String, String> _initial = {};
  final Map<String, String?> _fieldErrors = {};

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

    _bindValidationAutoRemoval();
    _loadUser();
  }

  void _bindValidationAutoRemoval() {
    for (final field in [
      'firstName',
      'lastName',
      'email',
      'username',
      'phoneNumber',
      'birthDate',
    ]) {
      ErrorAutoRemoval.removeErrorOnTextField(
        field: field,
        fieldErrors: _fieldErrors,
        controller: fields.controller(field),
        setState: () {
          if (mounted) setState(() {});
        },
      );
    }
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
      _fieldErrors.clear();
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

  bool _validateForm() {
    _fieldErrors.clear();

    final isValid = ValidationEngine.validate([
      Rules.requiredText(
        'firstName',
        fields.text('firstName'),
        'Ime je obavezno.',
      ),
      Rules.minLength(
        'firstName',
        fields.text('firstName'),
        2,
        'Ime mora imati najmanje 2 karaktera.',
      ),
      Rules.requiredText(
        'lastName',
        fields.text('lastName'),
        'Prezime je obavezno.',
      ),
      Rules.minLength(
        'lastName',
        fields.text('lastName'),
        2,
        'Prezime mora imati najmanje 2 karaktera.',
      ),
      Rules.email('email', fields.text('email')),
      Rules.username('username', fields.text('username')),
      Rules.phone(
        'phoneNumber',
        fields.text('phoneNumber'),
        required: true,
      ),
      Rules.requiredText(
        'birthDate',
        fields.text('birthDate'),
        'Datum rođenja je obavezan.',
      ),
    ], (field, message) {
      _fieldErrors[field] = message;
    });

    setState(() {});
    return isValid;
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
    final ok = _validateForm();
    if (!ok) return;

    final userId = Session.userId;
    if (userId == null) return;

    try {
      final oldImg = _user?.userImage;
      String? finalImage = oldImg;

      if (finalImage != null && finalImage.trim().isEmpty) {
        finalImage = null;
      }

      if (_pickedImage != null) {
        final uploadedFileName = await ImageAppProvider.upload(
          file: _pickedImage!,
          folder: "users",
        );
        finalImage = uploadedFileName;
      }

      final firstName = fields.text("firstName");
      final lastName = fields.text("lastName");
      final username = fields.text("username");

      await _userProvider.update(userId, {
        'firstName': firstName,
        'lastName': lastName,
        'email': fields.text("email"),
        'username': username,
        'phoneNumber': fields.text("phoneNumber"),
        'dateOfBirth': DateHelper.toIsoFromUi(fields.text("birthDate")),
        'userImage': finalImage,
        'isActive': _user?.isActive ?? true,
        'IsLoggingFirstTime': false,
        'isVlasnik': _user?.isVlasnik ?? false,
        'createdAt': _user?.createdAt.toIso8601String(),
        'lastLoginAt': _user?.lastLoginAt?.toIso8601String(),
      });

      if (_pickedImage != null &&
          oldImg != null &&
          oldImg.trim().isNotEmpty &&
          oldImg != finalImage) {
        await ImageAppProvider.delete(folder: "users", fileName: oldImg);
      }

      Session.fullName = "$firstName $lastName".trim();
      Session.username = username;
      Session.userImage = finalImage;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil je uspješno sačuvan.")),
      );

      await _loadUser();
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
      NameAndSurname: Session.fullName ?? "Nepoznato",
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
      child: Container(
        color: const Color(0xFFF6F7FB),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null)
                ? _ErrorState(message: _error!, onRetry: _loadUser)
                : _user == null
                    ? _ErrorState(
                        message: "Korisnik nije učitan.",
                        onRetry: _loadUser,
                      )
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
                                  fields: fields,
                                  fieldErrors: _fieldErrors,
                                  onAnyChanged: () => setState(() {}),
                                ),
                                const SizedBox(height: 14),
                              ],
                            ),
                          ),
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
    required this.fields,
    required this.fieldErrors,
    required this.onAnyChanged,
  });

  final Fields fields;
  final Map<String, String?> fieldErrors;
  final VoidCallback onAnyChanged;

  static const Color rentifyGreenDark = Color(0xFF5F9F3B);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _field(
                  label: "Ime",
                  controller: fields.controller("firstName"),
                  errorText: fieldErrors["firstName"],
                  onChanged: (_) => onAnyChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  label: "Prezime",
                  controller: fields.controller("lastName"),
                  errorText: fieldErrors["lastName"],
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
                  errorText: fieldErrors["email"],
                  onChanged: (_) => onAnyChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  label: "Username",
                  controller: fields.controller("username"),
                  errorText: fieldErrors["username"],
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
            errorText: fieldErrors["birthDate"],
            onAnyChanged: onAnyChanged,
          ),
          const SizedBox(height: 12),
          _field(
            label: "Telefon",
            controller: fields.controller("phoneNumber"),
            keyboardType: TextInputType.phone,
            errorText: fieldErrors["phoneNumber"],
            onChanged: (_) => onAnyChanged(),
          ),
        ],
      ),
    );
  }

  Widget _dateField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String? errorText,
    required VoidCallback onAnyChanged,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
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
    String? errorText,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
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