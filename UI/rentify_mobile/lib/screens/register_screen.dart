import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const Color rentifyGreen = Color(0xFFA9C64A);
  static const Color rentifyGreenDark = Color(0xFF5F9F3B);
  static const Color textDark = Color(0xFF2F2F2F);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // UI state (po želji)
  DateTime? _dob;
  bool _hasImage = false;

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

                          // ====== UBACI SVOJE BASE_FIELD WIDGETE OVDJE ======
                          _placeholderField("Ime (FirstName)"),
                          const SizedBox(height: 12),
                          _placeholderField("Prezime (LastName)"),
                          const SizedBox(height: 12),
                          _placeholderField("Korisničko ime (Username)"),
                          const SizedBox(height: 12),
                          _placeholderField("Email (Email)"),

                          const SizedBox(height: 18),
                          _sectionTitle("Kontakt"),
                          const SizedBox(height: 10),

                          _placeholderField("Broj telefona (PhoneNumber)"),

                          const SizedBox(height: 18),
                          _sectionTitle("Sigurnost"),
                          const SizedBox(height: 10),

                          _placeholderField("Lozinka (Password)"),
                          const SizedBox(height: 12),
                          _placeholderField("Potvrdi lozinku"),

                          const SizedBox(height: 18),
                          _sectionTitle("Dodatno"),
                          const SizedBox(height: 10),

                          _dateTile(
                            label: "Datum rođenja (DateOfBirth)",
                            valueText: _dob == null
                                ? "Odaberi datum"
                                : "${_dob!.day.toString().padLeft(2, '0')}.${_dob!.month.toString().padLeft(2, '0')}.${_dob!.year}",
                            onTap: _pickDate,
                          ),

                          const SizedBox(height: 16),
                          _infoNote(
                            "Registracijom preko aplikacije: IsActive = true i IsVlasnik = true.",
                          ),

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
                          onPressed: () {
                            // TODO: submit (pozovi svoj provider)
                            // payload obavezno: IsActive=true, IsVlasnik=true
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RegisterScreen.rentifyGreenDark,
                            foregroundColor: Colors.white,
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
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
  // UI HELPERS (Widget functions)
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
            child: Icon(
              _hasImage ? Icons.check_circle : Icons.person,
              color: RegisterScreen.rentifyGreenDark,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Profilna slika",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: RegisterScreen.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Odaberi sliku (opcionalno)",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6E6E6E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              // TODO: open image picker
              setState(() => _hasImage = true);
            },
            icon: const Icon(Icons.photo_library_outlined),
            color: RegisterScreen.rentifyGreenDark,
            tooltip: "Odaberi",
          ),
          IconButton(
            onPressed: () {
              // TODO: remove image
              setState(() => _hasImage = false);
            },
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
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9E9E9)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: RegisterScreen.rentifyGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontWeight: FontWeight.w700,
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
    );
  }

  Widget _infoNote(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
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

  Widget _placeholderField(String label) {
    return Container(
      height: 54,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8A8A8A),
          fontWeight: FontWeight.w700,
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

    if (picked != null) setState(() => _dob = picked);
  }
}