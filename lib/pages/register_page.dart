import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../main.dart';
import 'login_page.dart';
import '../providers/alarm_settings_provider.dart';
import '../providers/sleep_audio_provider.dart';

class RegisterPage extends StatefulWidget {
  final AlarmSettingsProvider alarmProvider;
  final SleepAudioProvider    audioProvider;

  const RegisterPage({
    super.key,
    required this.alarmProvider,
    required this.audioProvider,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  void _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Барлық өрістерді толтырыңыз');
      return;
    }

    if (!email.contains('@')) {
      _showError('Электрондық пошта қате енгізілді');
      return;
    }

    if (password.length < 6) {
      _showError('Құпиясөз кемінде 6 таңбадан тұруы керек');
      return;
    }

    if (password != confirmPassword) {
      _showError('Құпиясөздер сәйкес келмейді');
      return;
    }

    final settingsBox = Hive.box('settings');
    final Map<dynamic, dynamic> users = settingsBox.get('registered_users', defaultValue: {
      'user@sleep.ly': 'password123'
    });

    if (users.containsKey(email)) {
      _showError('Бұл электрондық пошта тіркелген');
      return;
    }


    users[email] = password;
    await settingsBox.put('registered_users', users);


    await settingsBox.put('is_logged_in', true);
    await settingsBox.put('current_user_email', email);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Тіркелу сәтті аяқталды', style: GoogleFonts.montserrat()),
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

              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => LoginPage(
                        alarmProvider: widget.alarmProvider,
                        audioProvider: widget.audioProvider,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back_ios, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Back',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),


              Text(
                'Let\'s get\nStarted',
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
              const SizedBox(height: 16),


              _buildTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              const SizedBox(height: 28),


              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Sign up',
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
              const SizedBox(height: 36),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => LoginPage(
                            alarmProvider: widget.alarmProvider,
                            audioProvider: widget.audioProvider,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Login',
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
