import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../main.dart';
import 'register_page.dart';
import '../providers/alarm_settings_provider.dart';
import '../providers/sleep_audio_provider.dart';

class LoginPage extends StatefulWidget {
  final AlarmSettingsProvider alarmProvider;
  final SleepAudioProvider    audioProvider;

  const LoginPage({
    super.key,
    required this.alarmProvider,
    required this.audioProvider,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Барлық өрістерді толтырыңыз');
      return;
    }

    final settingsBox = Hive.box('settings');

    final Map<dynamic, dynamic> users = settingsBox.get('registered_users', defaultValue: {
      'user@sleep.ly': 'password123'
    });


    if (!settingsBox.containsKey('registered_users')) {
      await settingsBox.put('registered_users', users);
    }

    if (users.containsKey(email) && users[email] == password) {

      await settingsBox.put('is_logged_in', true);
      await settingsBox.put('current_user_email', email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Авторизация сәтті аяқталды', style: GoogleFonts.montserrat()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainShell(
              alarmProvider: widget.alarmProvider,
              audioProvider: widget.audioProvider,
            ),
          ),
        );
      }
    } else {
      _showError('Қате электрондық пошта немесе құпиясөз');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),


              Text(
                'Welcome\nBack',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 36),


              _buildTextField(
                controller: _emailController,
                hintText: 'Email id',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),


              _buildTextField(
                controller: _passwordController,
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 28),


              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),


              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[900], thickness: 1.5)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: GoogleFonts.montserrat(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[900], thickness: 1.5)),
                ],
              ),
              const SizedBox(height: 24),


              _buildOAuthButton(
                icon: const Icon(Icons.apple, color: Colors.white, size: 22),
                text: 'Continue with Apple',
                onPressed: () {},
              ),
              const SizedBox(height: 12),


              _buildOAuthButton(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('G', style: GoogleFonts.montserrat(color: const Color(0xFF4285F4), fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('o', style: GoogleFonts.montserrat(color: const Color(0xFFEA4335), fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('o', style: GoogleFonts.montserrat(color: const Color(0xFFFBBC05), fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('g', style: GoogleFonts.montserrat(color: const Color(0xFF4285F4), fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('l', style: GoogleFonts.montserrat(color: const Color(0xFF34A853), fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('e', style: GoogleFonts.montserrat(color: const Color(0xFFEA4335), fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                text: 'Continue with Google',
                onPressed: () {},
              ),
              const SizedBox(height: 48),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New user? ',
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => RegisterPage(
                            alarmProvider: widget.alarmProvider,
                            audioProvider: widget.audioProvider,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Sign up',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.montserrat(color: Colors.grey[700], fontSize: 15),
          prefixIcon: Icon(prefixIcon, color: Colors.grey[600], size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildOAuthButton({
    required Widget icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF161618),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
