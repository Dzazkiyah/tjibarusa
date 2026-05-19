// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _loading = false;
  bool _obscure = true;

  // Login
  final _loginEmail    = TextEditingController();
  final _loginPassword = TextEditingController();
  String? _loginError;

  // Register
  final _regName     = TextEditingController();
  final _regEmail    = TextEditingController();
  final _regPassword = TextEditingController();
  String? _regError;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _regName.dispose();
    _regEmail.dispose();
    _regPassword.dispose();
    super.dispose();
  }

  // FIX: pop dulu balik ke HomeScreen lama, baru panggil callback
  void _goHome() {
    if (!mounted) return;
    Navigator.pop(context);
    widget.onLoginSuccess?.call();
  }

  // FIX: skip tanpa login — cukup pop, JANGAN panggil onLoginSuccess
  void _skipToHome() {
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _login() async {
    if (_loginEmail.text.trim().isEmpty ||
        _loginPassword.text.trim().isEmpty) {
      setState(() => _loginError = 'Email dan password tidak boleh kosong.');
      return;
    }
    setState(() {
      _loading = true;
      _loginError = null;
    });

    final err = await AuthService.login(
      email: _loginEmail.text,
      password: _loginPassword.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      setState(() => _loginError = err);
    } else {
      _goHome();
    }
  }

  Future<void> _register() async {
    if (_regName.text.trim().isEmpty) {
      setState(() => _regError = 'Nama tidak boleh kosong.');
      return;
    }
    if (_regEmail.text.trim().isEmpty) {
      setState(() => _regError = 'Email tidak boleh kosong.');
      return;
    }
    if (_regPassword.text.length < 6) {
      setState(() => _regError = 'Password minimal 6 karakter.');
      return;
    }

    setState(() {
      _loading = true;
      _regError = null;
    });

    final err = await AuthService.register(
      name: _regName.text,
      email: _regEmail.text,
      password: _regPassword.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      setState(() => _regError = err);
    } else {
      _goHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Stack(
        children: [
          // ── Background dekorasi ──────────────────────────────────────────
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navyDeep.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 40, left: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: mobile ? 24 : 80,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header ─────────────────────────────────────────
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Tjibarusa',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyDeep,
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 4),
                          Text(
                            'Masuk untuk pengalaman lengkap',
                            style: AppText.body(13, color: AppColors.grey500),
                          ).animate().fadeIn(delay: 300.ms),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ── Tab Bar ────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TabBar(
                          controller: _tab,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: AppColors.navyDeep,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.navyDeep.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          labelColor: AppColors.white,
                          unselectedLabelColor: AppColors.grey500,
                          labelStyle: AppText.label(14, color: AppColors.white),
                          unselectedLabelStyle:
                              AppText.label(14, color: AppColors.grey500),
                          dividerColor: Colors.transparent,
                          tabs: const [
                            Tab(text: 'Masuk'),
                            Tab(text: 'Daftar'),
                          ],
                        ),
                      ).animate().fadeIn(delay: 350.ms),

                      const SizedBox(height: 24),

                      // ── Form ───────────────────────────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _tab.index == 0
                            ? _loginForm()
                            : _registerForm(),
                      ),

                      const SizedBox(height: 32),

                      // ── Skip button ────────────────────────────────────
                      Column(
                        children: [
                          Row(children: [
                            Expanded(child: Divider(color: AppColors.grey200)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('atau',
                                  style: AppText.body(12, color: AppColors.grey400)),
                            ),
                            Expanded(child: Divider(color: AppColors.grey200)),
                          ]),
                          const SizedBox(height: 14),
                          // FIX: pakai _skipToHome, bukan _goHome
                          GestureDetector(
                            onTap: _skipToHome,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.grey300, width: 1.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Lihat dulu tanpa login',
                                    style: AppText.label(14, color: AppColors.grey600),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward_rounded,
                                      size: 16, color: AppColors.grey500),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Check-in, kuis, dan profil butuh login',
                            style: AppText.body(11, color: AppColors.grey400),
                          ),
                        ],
                      ).animate().fadeIn(delay: 500.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Login form ──────────────────────────────────────────────────────────────
  Widget _loginForm() => Column(
        key: const ValueKey('login'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InputField(
            controller: _loginEmail,
            hint: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _InputField(
            controller: _loginPassword,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18, color: AppColors.grey500,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          if (_loginError != null) ...[
            const SizedBox(height: 10),
            _ErrorBanner(_loginError!),
          ],
          const SizedBox(height: 20),
          _PrimaryButton(
            label: 'Masuk',
            loading: _loading,
            onTap: _login,
          ),
        ],
      );

  // ── Register form ───────────────────────────────────────────────────────────
  Widget _registerForm() => Column(
        key: const ValueKey('register'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InputField(
            controller: _regName,
            hint: 'Nama Lengkap',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12),
          _InputField(
            controller: _regEmail,
            hint: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _InputField(
            controller: _regPassword,
            hint: 'Password (min. 6 karakter)',
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18, color: AppColors.grey500,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          if (_regError != null) ...[
            const SizedBox(height: 10),
            _ErrorBanner(_regError!),
          ],
          const SizedBox(height: 20),
          _PrimaryButton(
            label: 'Daftar',
            loading: _loading,
            onTap: _register,
          ),
        ],
      );
}

// ─── Input Field ──────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: AppText.body(14, color: AppColors.navyDeep),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.body(14, color: AppColors.grey400),
            prefixIcon: Icon(icon, size: 20, color: AppColors.grey400),
            suffixIcon: suffixIcon,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
          ),
        ),
      );
}

// ─── Error Banner ─────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFBE9E7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded,
              size: 16, color: Color(0xFFE53935)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: AppText.body(12, color: const Color(0xFFB71C1C))),
          ),
        ]),
      );
}

// ─── Primary Button ───────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: loading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navyDeep,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.grey300,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: AppColors.white),
                )
              : Text(label,
                  style: AppText.heading(15, color: AppColors.white)),
        ),
      );
}