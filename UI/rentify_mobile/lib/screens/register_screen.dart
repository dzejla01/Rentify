import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/dialogs/confirmation_dialogs.dart';
import 'package:rentify_mobile/helper/date_helper.dart';
import 'package:rentify_mobile/routes/app_routes.dart';
import 'package:rentify_mobile/providers/user_provider.dart';
import 'package:rentify_mobile/helper/text_editing_controller_helper.dart'; 
import 'package:rentify_mobile/validation/validation_model/validation_field_rule.dart'; 
import 'package:rentify_mobile/validation/validation_model/validation_rules.dart'; 
import 'package:rentify_mobile/validation/validation_use/universal_error_removal.dart'; 
import 'package:rentify_mobile/validation/validation_use/universal_validator.dart'; 

// upload slike (ako ti je drugačije, preimenuj)
import 'package:rentify_mobile/providers/image_provider.dart' as img_app;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const Color rentifyGreen = Color(0xFFA9C64A);
  static const Color rentifyGreenDark = Color(0xFF5F9F3B);
  static const Color textDark = Color(0xFF2F2F2F);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late UserProvider _userProvider;

  late Fields fields;

  // errors po polju
  final Map<String, String?> fieldErrors = {};

  // UI state
  DateTime? _dob;
  File? _pickedImage;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    _userProvider = Provider.of<UserProvider>(context, listen: false);

    fields = Fields.fromNames([
      'firstName',
      'lastName',
      'username',
      'email',
      'phoneNumber',
      'password',
      'confirmPassword',
    ]);

    // auto-remove error na unos
    ErrorAutoRemoval.removeErrorOnTextField(
      field: 'firstName',
      fieldErrors: fieldErrors,
      controller: fields.controller('firstName'),
      setState: () => setState(() {}),
    );
    ErrorAutoRemoval.removeErrorOnTextField(
      field: 'lastName',
      fieldErrors: fieldErrors,
      controller: fields.controller('lastName'),
      setState: () => setState(() {}),
    );
    ErrorAutoRemoval.removeErrorOnTextField(
      field: 'username',
      fieldErrors: fieldErrors,
      controller: fields.controller('username'),
      setState: () => setState(() {}),
    );
    ErrorAutoRemoval.removeErrorOnTextField(
      field: 'email',
      fieldErrors: fieldErrors,
      controller: fields.controller('email'),
      setState: () => setState(() {}),
    );
    ErrorAutoRemoval.removeErrorOnTextField(
      field: 'phoneNumber',
      fieldErrors: fieldErrors,
      controller: fields.controller('phoneNumber'),
      setState: () => setState(() {}),
    );
    ErrorAutoRemoval.removeErrorOnTextField(
      field: 'password',
      fieldErrors: fieldErrors,
      controller: fields.controller('password'),
      setState: () => setState(() {}),
    );
    ErrorAutoRemoval.removeErrorOnTextField(
      field: 'confirmPassword',
      fieldErrors: fieldErrors,
      controller: fields.controller('confirmPassword'),
      setState: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    fields.dispose();
    super.dispose();
  }

  bool get _hasImage => _pickedImage != null;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFBFE06A),
              RegisterScreen.rentifyGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 24,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _header(),
                          const SizedBox(height: 18),

                          _avatarPicker(),
                          const SizedBox(height: 18),

                          _sectionTitle("Osnovni podaci"),
                          const SizedBox(height: 10),

                          _field(
                            label: "Ime",
                            controller: fields.controller('firstName'),
                            errorText: fieldErrors['firstName'],
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),

                          _field(
                            label: "Prezime",
                            controller: fields.controller('lastName'),
                            errorText: fieldErrors['lastName'],
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),

                          _field(
                            label: "Korisničko ime",
                            controller: fields.controller('username'),
                            errorText: fieldErrors['username'],
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),

                          _field(
                            label: "Email",
                            controller: fields.controller('email'),
                            errorText: fieldErrors['email'],
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 18),
                          _sectionTitle("Kontakt"),
                          const SizedBox(height: 10),

                          _field(
                            label: "Broj telefona",
                            controller: fields.controller('phoneNumber'),
                            errorText: fieldErrors['phoneNumber'],
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 18),
                          _sectionTitle("Sigurnost"),
                          const SizedBox(height: 10),

                          _field(
                            label: "Lozinka",
                            controller: fields.controller('password'),
                            errorText: fieldErrors['password'],
                            obscure: true,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),

                          _field(
                            label: "Potvrdi lozinku",
                            controller: fields.controller('confirmPassword'),
                            errorText: fieldErrors['confirmPassword'],
                            obscure: true,
                            textInputAction: TextInputAction.done,
                          ),

                          const SizedBox(height: 18),
                          _sectionTitle("Dodatno"),
                          const SizedBox(height: 10),

                          _dateTile(
                            label: "Datum rođenja",
                            valueText: _dob == null
                                ? "Odaberi datum"
                                : "${_dob!.day.toString().padLeft(2, '0')}.${_dob!.month.toString().padLeft(2, '0')}.${_dob!.year}",
                            onTap: _pickDate,
                            errorText: fieldErrors['birthDate'],
                          ),

                          const SizedBox(height: 12),
                          _infoNote(),

                          const SizedBox(height: 10),
                          _backToLogin(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Sticky button
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16 + (bottomInset > 0 ? 10 : 0),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: SizedBox(
                        height: 54,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RegisterScreen.rentifyGreenDark,
                            foregroundColor: Colors.white,
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.6,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Registruj se",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------
  // UI HELPERS
  // --------------------

  Widget _header() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                'assets/images/rentify_single_R_green.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Rentify",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: RegisterScreen.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "Kreiraj korisnički račun",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6E6E6E),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: RegisterScreen.textDark,
      ),
    );
  }

  Widget _avatarPicker() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E2E2)),
            ),
            child: _pickedImage != null
                ? ClipOval(child: Image.file(_pickedImage!, fit: BoxFit.cover))
                : Icon(
                    _hasImage ? Icons.check_circle : Icons.person,
                    color: RegisterScreen.rentifyGreenDark,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Profilna slika",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: RegisterScreen.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _hasImage ? "Slika odabrana" : "Odaberi sliku (opcionalno)",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6E6E6E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library_outlined),
            color: RegisterScreen.rentifyGreenDark,
            tooltip: "Odaberi",
          ),
          IconButton(
            onPressed: _pickedImage == null ? null : _removeImage,
            icon: const Icon(Icons.delete_outline),
            color: const Color(0xFF8A8A8A),
            tooltip: "Ukloni",
          ),
        ],
      ),
    );
  }

  Widget _dateTile({
    required String label,
    required String valueText,
    required VoidCallback onTap,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (errorText != null) ? const Color(0xFFE53935) : const Color(0xFFE9E9E9),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: RegisterScreen.rentifyGreen,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF8A8A8A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  valueText,
                  style: const TextStyle(
                    color: Color(0xFF6E6E6E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Color(0xFF8A8A8A)),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Color(0xFF7A7A7A)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Registracijom preko aplikacije: IsActive = true i IsVlasnik = true.",
              style: TextStyle(
                color: Color(0xFF6E6E6E),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backToLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Već imaš račun?",
          style: TextStyle(
            color: Color(0xFF6E6E6E),
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Prijavi se",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: RegisterScreen.rentifyGreenDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? errorText,
    bool obscure = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: (errorText != null) ? const Color(0xFFE53935) : const Color(0xFFE9E9E9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: RegisterScreen.rentifyGreenDark),
        ),
      ),
    );
  }

  // --------------------
  // ACTIONS
  // --------------------

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 100, 1, 1);
    final lastDate = DateTime(now.year - 10, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20, 1, 1),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: "Datum rođenja",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: RegisterScreen.rentifyGreenDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _dob = picked;
      // ukloni error za birthDate ako postoji
      if (fieldErrors['birthDate'] != null) {
        fieldErrors.remove('birthDate');
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;

      setState(() => _pickedImage = File(file.path));
    } catch (e) {
      if (!mounted) return;
      await ConfirmDialogs.okConfirmation(
        context,
        title: "Greška",
        message: "Ne mogu otvoriti galeriju.\n$e",
      );
    }
  }

  void _removeImage() => setState(() => _pickedImage = null);

  Future<void> _submit() async {
    // očisti stare greške
    setState(() => fieldErrors.clear());

    // složi pravila (koristimo tvoja Rules + par custom FieldRule)
    final rules = <FieldRule>[
      Rules.requiredText('firstName', fields.text('firstName'), 'Ime je obavezno.'),
      Rules.requiredText('lastName', fields.text('lastName'), 'Prezime je obavezno.'),
      Rules.requiredText('username', fields.text('username'), 'Username je obavezan.'),
      Rules.minLength('username', fields.text('username'), 3, 'Username mora imati bar 3 karaktera.'),

      Rules.requiredText('email', fields.text('email'), 'Email je obavezan.'),
      FieldRule('email', () {
        final s = fields.text('email').trim();
        final ok = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(s);
        return ok ? null : 'Email nije ispravan.';
      }),

      Rules.requiredText('phoneNumber', fields.text('phoneNumber'), 'Telefon je obavezan.'),
      FieldRule('phoneNumber', () {
        final s = fields.text('phoneNumber').trim();
        return s.length >= 6 ? null : 'Telefon nije ispravan.';
      }),

      Rules.requiredText('password', fields.text('password'), 'Lozinka je obavezna.'),
      Rules.minLength('password', fields.text('password'), 6, 'Lozinka mora imati bar 6 karaktera.'),

      Rules.requiredText('confirmPassword', fields.text('confirmPassword'), 'Potvrda lozinke je obavezna.'),
      FieldRule('confirmPassword', () {
        return fields.text('confirmPassword') == fields.text('password')
            ? null
            : 'Lozinke se ne podudaraju.';
      }),

      Rules.requiredDate('birthDate', _dob, 'Datum rođenja je obavezan.'),
    ];

    final isValid = ValidationEngine.validate(
      rules,
      (field, message) {
        fieldErrors[field] = message;
      },
    );

    if (!isValid) {
      setState(() {});
      return;
    }

    setState(() => _submitting = true);

    try {
      String? uploadedImageName;

      if (_pickedImage != null) {
        uploadedImageName = await img_app.ImageAppProvider.upload(
          file: _pickedImage!,
          folder: "users",
        );
      }

      final payload = <String, dynamic>{
        'firstName': fields.text('firstName').trim(),
        'lastName': fields.text('lastName').trim(),
        'username': fields.text('username').trim(),
        'email': fields.text('email').trim(),
        'phoneNumber': fields.text('phoneNumber').trim(),
        'password': fields.text('password'),
        'dateOfBirth': DateHelper.toUtcIsoNullable(_dob),
        'isActive': true,
        'isVlasnik': false,
        'IsLoggingFirstTime': true,

        if (uploadedImageName != null) 'userImage': uploadedImageName,
      };

      await _userProvider.insert(payload);

      if (!mounted) return;

      await ConfirmDialogs.okConfirmation(
        context,
        title: "Uspješno",
        message: "Račun je kreiran. Sada se možeš prijaviti.",
      );

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      await ConfirmDialogs.okConfirmation(
        context,
        title: "Greška",
        message: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}