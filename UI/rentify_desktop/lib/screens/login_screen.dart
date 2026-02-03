import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_desktop/helper/snackBar_helper.dart';
import 'package:rentify_desktop/models/login_request.dart';
import 'package:rentify_desktop/providers/auth_provider.dart';
import 'package:rentify_desktop/routes/app_routes.dart';
import 'package:rentify_desktop/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const Color rentifyGreen = Color(0xFFA9C64A);
  static const Color rentifyGreenDark = Color(0xFF5F9F3B);
  static const Color textDark = Color(0xFF4A4A4A);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  late AuthProvider _authProvider;
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();

  bool? _hoverForForgotPassword;

  Future<void> _forgotPasswordOrUsername() async{


  }


  Future<void> login() async{
    final result = await _authProvider.prijava(
    LoginRequest(
      username: _username.text.trim(),
      password: _password.text,
    ),
  );

  if (result == "ZABRANJENO") {
    SnackbarHelper.showError(
      context,
      'Nemate privilegije za pristup aplikaciji',
    );
    return;
  }

  if (result != "OK") {
    SnackbarHelper.showError(
      context,
      'Pogrešno korisničko ime ili lozinka',
    );
    return;
  }

  Navigator.pushReplacementNamed(context, AppRoutes.home);
 }

 @override
 void dispose() {
   _username.dispose();
   _password.dispose();
   super.dispose();
 }

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.1,
            colors: [
              Color(0xFFBFE06A),
              LoginScreen.rentifyGreen,
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 26,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 54,
                          height: 104,
                          child: Image.asset(
                            'assets/images/rentify_single_R_green.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          child: const Text(
                            'Rentify',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              color: LoginScreen.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(height: 1, color: Color(0xFFE8E8E8)),
                    const SizedBox(height: 18),
                    _inputField(
                      controller: _username,
                      hintText: 'Korisničko ime',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 14),
                    _inputField(
                      controller: _password,
                      hintText: 'Lozinka',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LoginScreen.rentifyGreenDark,
                          foregroundColor: Colors.white,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Uloguj se',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _hoverForForgotPassword = true),
                      onExit: (_) => setState(() => _hoverForForgotPassword = false),
                      child: GestureDetector(
                        onTap: () {
                          _forgotPasswordOrUsername();
                        },
                        child: const Text(
                          'Zaboravili ste korisničko ime ili lozinku?',
                          style: TextStyle(
                            color: Color(0xFF7A7A7A),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          prefixIcon: Icon(icon, color: LoginScreen.rentifyGreen),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: LoginScreen.rentifyGreen, width: 2),
          ),
        ),
      ),
    );
  }
}
