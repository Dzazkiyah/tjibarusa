// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OnboardingPrefs {
  static const _key = 'onboarding_done';
  static Future<bool> isDone() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_key) ?? false;
  }
  static Future<void> setDone() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, true);
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  void _next() {
    if (_page < 2) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await OnboardingPrefs.setDone();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              _Page1(onNext: _next),
              _Page2(onNext: _next, onSkip: _finish),
              _Page3(onFinish: _finish),
            ],
          ),

          // Skip button
          if (_page < 2)
            Positioned(
              top: 0, right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20, top: 8),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text('Lewati',
                        style: AppText.body(13,
                            color: AppColors.white.withOpacity(0.7))),
                  ),
                ),
              ),
            ),

          // Dot indicator
          Positioned(
            bottom: 28, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 24 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _page == i
                      ? AppColors.white
                      : AppColors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(100),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// PAGE 1 — SPLASH full blue gradient
// ════════════════════════════════════════════════════════════════════════════════
class _Page1 extends StatelessWidget {
  final VoidCallback onNext;
  const _Page1({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.blueDark,
            AppColors.blueDeep,
            Color(0xFF1D4ED8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Dekorasi lingkaran
          Positioned(top: -80, right: -80,
              child: _Bubble(size: 260, opacity: 0.08)),
          Positioned(bottom: 60, left: -100,
              child: _Bubble(size: 340, opacity: 0.06)),
          Positioned(top: 200, left: -50,
              child: _Bubble(size: 140, opacity: 0.06)),
          Positioned(top: 100, right: 40,
              child: _Bubble(size: 70, opacity: 0.10)),
          Positioned(bottom: 200, right: 20,
              child: _Bubble(size: 50, opacity: 0.12)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo container — glassy
                  Container(
                    width: 96, height: 96,
                  )
                      .animate()
                      .scale(
                          begin: const Offset(0.6, 0.6),
                          duration: 800.ms,
                          curve: Curves.elasticOut)
                      .fadeIn(),

                  const SizedBox(height: 36),

                  Text('Tjibarusa',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 52,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        letterSpacing: -1,
                      ))
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 6),

                  Text('K A B U P A T E N   B E K A S I',
                      style: AppText.caps(
                          size: 11,
                          color: AppColors.white.withOpacity(0.60)))
                      .animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 10),

                  Text('Wilujeung Sumping',
                      style: AppText.script(
                          size: 24,
                          color: AppColors.white.withOpacity(0.80)))
                      .animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 28),

                  // Divider dekoratif
                  Row(children: [
                    Expanded(
                        child: Divider(
                            color: AppColors.white.withOpacity(0.2))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                            color: AppColors.white.withOpacity(0.2))),
                  ]).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 22),

                  Text(
                    'Jelajahi keindahan alam, kuliner khas,\ndan budaya warisan Cibarusah',
                    style: AppText.body(14,
                        color: AppColors.white.withOpacity(0.72)),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 800.ms),

                  const Spacer(flex: 2),

                  // CTA button — putih/glassy
                  GestureDetector(
                    onTap: onNext,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blueDark.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Mulai',
                              style: AppText.label(16,
                                  color: AppColors.blueDeep)),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                              color: AppColors.blueDeep, size: 18),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 72),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// PAGE 2 — MASKOT dengan soft blue background
// ════════════════════════════════════════════════════════════════════════════════
class _Page2 extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  const _Page2({required this.onNext, required this.onSkip});

  @override
  State<_Page2> createState() => _Page2State();
}

class _Page2State extends State<_Page2> {
  bool _showGalih = false;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1440A0),
            Color(0xFF2563EB),
            Color(0xFFEFF6FF),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(children: [
                  _ToggleBtn(
                    label: '👧 Wening',
                    active: !_showGalih,
                    onTap: () => setState(() => _showGalih = false),
                    activeColor: AppColors.white,
                    activeTxt: AppColors.blueDeep,
                    inactiveTxt: AppColors.white.withOpacity(0.7),
                  ),
                  _ToggleBtn(
                    label: '👦 Galih',
                    active: _showGalih,
                    onTap: () => setState(() => _showGalih = true),
                    activeColor: AppColors.white,
                    activeTxt: AppColors.blueDeep,
                    inactiveTxt: AppColors.white.withOpacity(0.7),
                  ),
                ]),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('Kenalan yuk!',
                    style: AppText.label(12, color: AppColors.white)),
              ).animate().fadeIn(delay: 200.ms),

              const Spacer(),

              // Mascot
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _showGalih
                    ? _MascotImage(
                        key: const ValueKey('galih'),
                        path: 'assets/images/image2.png',
                        height: screenH * 0.30,
                      )
                    : _MascotImage(
                        key: const ValueKey('wening'),
                        path: 'assets/images/image3.png',
                        height: screenH * 0.30,
                      ),
              ),

              const Spacer(),

              // Speech bubble — putih, bawah gradient
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showGalih
                    ? _MascotSpeech(
                        key: const ValueKey('galih-text'),
                        name: 'Galih',
                        emoji: '👦',
                        color: AppColors.blueDeep,
                        message:
                            'Halo! Aku Galih, penjelajah setia Cibarusah! Yuk aku ajak kamu keliling tempat wisata, kuliner enak, dan sejarah yang seru di sini!',
                      )
                    : _MascotSpeech(
                        key: const ValueKey('wening-text'),
                        name: 'Wening',
                        emoji: '👧',
                        color: AppColors.blueDeep,
                        message:
                            'Hai! Aku Wening, artinya bening seperti air sungai Cibarusah! Aku akan menemanimu mengenal budaya, kuliner, dan keindahan Cibarusah!',
                      ),
              ),

              const Spacer(),

              // Next button
              GestureDetector(
                onTap: widget.onNext,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blueDark.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lanjut',
                          style: AppText.label(16,
                              color: AppColors.blueDeep)),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded,
                          color: AppColors.blueDeep, size: 18),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 72),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// PAGE 3 — FITUR  ← FIX: pakai SingleChildScrollView + hapus Spacer
// ════════════════════════════════════════════════════════════════════════════════
class _Page3 extends StatelessWidget {
  final VoidCallback onFinish;
  const _Page3({required this.onFinish});

  static const _features = [
    (emoji: '🗺️', title: 'Jelajahi Wisata',
        desc: 'Temukan tempat-tempat indah di Cibarusah',
        color: Color(0xFF1D4ED8)),
    (emoji: '📍', title: 'Check-in & Award',
        desc: 'Kunjungi wisata, upload foto, kumpulkan badge',
        color: Color(0xFF0EA5E9)),
    (emoji: '🧠', title: 'Kuis Sejarah',
        desc: 'Uji pengetahuan, raih lencana Penjaga Sejarah',
        color: Color(0xFF8B5CF6)),
    (emoji: '🍛', title: 'Kuliner Khas',
        desc: 'Gabus Pucung, Asinan, dan cita rasa Betawi-Sunda',
        color: Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2563EB),
            Color(0xFFEFF6FF),
          ],
          stops: [0.0, 0.4],
        ),
      ),
      // ── FIX: SafeArea + Column dengan button di bawah
      child: SafeArea(
        child: Column(
          children: [
            // ── Konten utama bisa scroll kalau layar kecil
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    // Header
                    Text(
                      'Semua ada di\nTjibarusa!',
                      style: AppText.display(30, color: AppColors.white),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 8),

                    Text(
                      'Satu aplikasi untuk mengenal Cibarusah',
                      style: AppText.body(13,
                          color: AppColors.white.withOpacity(0.82)),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 28),

                    // Feature cards
                    ...List.generate(_features.length, (i) {
                      final f = _features[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blueDeep.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(children: [
                            Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                color: f.color.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(f.emoji,
                                    style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f.title,
                                      style: AppText.heading(14)),
                                  const SizedBox(height: 3),
                                  Text(f.desc,
                                      style: AppText.body(12),
                                      maxLines: 2),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: AppColors.grey300, size: 20),
                          ]),
                        )
                            .animate()
                            .fadeIn(
                                delay: Duration(
                                    milliseconds: 100 + i * 100))
                            .slideX(begin: 0.15, end: 0),
                      );
                    }),

                    // Spasi bawah sebelum button
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── CTA button — tetap di bawah, tidak ikut scroll
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: GestureDetector(
                onTap: onFinish,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.blueDeep, AppColors.blueMid],
                    ),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blueDeep.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Mulai Jelajah! 🌾',
                          style: AppText.label(16,
                              color: AppColors.white)),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms)
                  .scale(
                      begin: const Offset(0.95, 0.95),
                      duration: 300.ms),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────
class _Bubble extends StatelessWidget {
  final double size, opacity;
  const _Bubble({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white.withOpacity(opacity),
        ),
      );
}

class _MascotImage extends StatelessWidget {
  final String path;
  final double height;
  const _MascotImage(
      {super.key, required this.path, required this.height});

  @override
  Widget build(BuildContext context) => Image.asset(
        path,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => SizedBox(
          height: height,
          child: const Center(
            child: Icon(Icons.person_rounded,
                size: 80, color: AppColors.bluePastel),
          ),
        ),
      );
}

class _MascotSpeech extends StatelessWidget {
  final String name, emoji, message;
  final Color color;
  const _MascotSpeech({
    super.key,
    required this.name,
    required this.emoji,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(name,
                style: AppText.display(22, color: AppColors.blueDark)),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.blueGhost,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.bluePastel),
            ),
            child: Text(
              message,
              style: AppText.body(13, color: AppColors.grey700),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color activeColor, activeTxt, inactiveTxt;

  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.onTap,
    required this.activeColor,
    required this.activeTxt,
    required this.inactiveTxt,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: active ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.blueDark.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppText.label(13,
                  color: active ? activeTxt : inactiveTxt),
            ),
          ),
        ),
      );
}