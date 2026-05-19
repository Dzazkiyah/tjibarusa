// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/auth_gate.dart';
import '../widgets/cibarusah_map_widget.dart';
import 'kuis_screen.dart';
import 'checkin_screen.dart';
import 'profile_screen.dart';
import 'detail_wisata_screen.dart';
import 'detail_sejarah_screen.dart';
import 'detail_kuliner_screen.dart';
import 'detail_berita_screen.dart';
import 'detail_batik_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scroll = ScrollController();
  bool _scrolled = false;
  int _budayaIdx = 0;
  int _navIdx = 0;

  final _keyHero    = GlobalKey();
  final _keyLokasi  = GlobalKey();
  final _keyBudaya  = GlobalKey();
  final _keyWisata  = GlobalKey();
  final _keyKuliner = GlobalKey();
  final _keyBerita  = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final s = _scroll.offset > 40;
      if (s != _scrolled) setState(() => _scrolled = s);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut);
  }

  void _onDesktopNav(int i) {
    switch (i) {
      case 0: _scrollTo(_keyHero);    break;
      case 1: _scrollTo(_keyLokasi);  break;
      case 2: _scrollTo(_keyBudaya);  break;
      case 3: _scrollTo(_keyWisata);  break;
      case 4: _scrollTo(_keyKuliner); break;
      case 5: _scrollTo(_keyBerita);  break;
    }
  }

  void _onBottomNav(int i) {
    switch (i) {
      case 0:
        setState(() => _navIdx = 0);
        break;
      case 1:
        AuthGate.require(context, () {
          if (!mounted) return;
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const KuisScreen()))
              .then((_) { if (mounted) setState(() => _navIdx = 0); });
        });
        break;
      case 2:
        AuthGate.require(context, () {
          if (!mounted) return;
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CheckInScreen()))
              .then((_) { if (mounted) setState(() => _navIdx = 0); });
        });
        break;
      case 3:
        AuthGate.require(context, () {
          if (!mounted) return;
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()))
              .then((_) { if (mounted) setState(() => _navIdx = 0); });
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: mobile ? _mobileAppBar() : _desktopAppBar(),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scroll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroSection(key: _keyHero,
                    onJelajahi: () => _scrollTo(_keyLokasi)),

                if (mobile)
                  _QuickAccessSection(
                    onWisata:  () => _scrollTo(_keyWisata),
                    onKuliner: () => _scrollTo(_keyKuliner),
                    onBudaya:  () => _scrollTo(_keyBudaya),
                    onBerita:  () => _scrollTo(_keyBerita),
                    onLokasi:  () => _scrollTo(_keyLokasi),
                    onKuis: () => AuthGate.require(context, () {
                      if (!mounted) return;
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const KuisScreen()));
                    }),
                  ),

                _gap(),
                _TeritoralSection(key: _keyLokasi),
                _gap(),
                _SejarahBudayaSection(
                  key: _keyBudaya,
                  selected: _budayaIdx,
                  onSelect: (i) => setState(() => _budayaIdx = i),
                  onBaca: (item) {
                    if (item.type == 'batik') {
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => DetailBatikScreen(budaya: item)));
                    } else {
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => DetailSejarahScreen(budaya: item)));
                    }
                  },
                  onKuis: () => AuthGate.require(context, () {
                    if (!mounted) return;
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const KuisScreen()));
                  }),
                ),
                _gap(),
                _WisataSection(
                  key: _keyWisata,
                  onTap: (w) => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => DetailWisataScreen(wisata: w))),
                ),
                _gap(),
                _KulinerSection(
                  key: _keyKuliner,
                  onTap: (k) => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => DetailKulinerScreen(kuliner: k))),
                ),
                _gap(),
                _BeritaSection(
                  key: _keyBerita,
                  onTap: (b) => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => DetailBeritaScreen(berita: b))),
                ),
                _FooterSection(onNavTap: _onDesktopNav),
                if (mobile) const SizedBox(height: 88),
              ],
            ),
          ),

          if (mobile)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _ModernBottomNav(
                  selected: _navIdx, onTap: _onBottomNav),
            ),
        ],
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 64);

  PreferredSizeWidget _mobileAppBar() => PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: _scrolled
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.blueDark, AppColors.blueDeep],
                  )
                : null,
            color: _scrolled ? null : Colors.transparent,
            boxShadow: _scrolled
                ? [BoxShadow(
                    color: AppColors.blueDark.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )]
                : null,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tjibarusa',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  PreferredSizeWidget _desktopAppBar() => PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: _scrolled
                ? const LinearGradient(
                    colors: [AppColors.blueDark, AppColors.blueDeep])
                : null,
            color: _scrolled ? null : Colors.transparent,
          ),
          child: CW(
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _onDesktopNav(0),
                    child: Row(children: [
                      Text('🏔️', style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text('Tjibarusa',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white)),
                    ]),
                  ),
                  const Spacer(),
                  ...['Beranda', 'Lokasi', 'Tentang',
                      'Wisata', 'Kuliner', 'Berita']
                      .asMap()
                      .entries
                      .map((e) => _NavLabel(e.value,
                          onTap: () => _onDesktopNav(e.key))),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => AuthGate.require(context, () {
                      if (!mounted) return;
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const KuisScreen()));
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(children: [
                        const Icon(Icons.quiz_rounded,
                            color: AppColors.blueDark, size: 14),
                        const SizedBox(width: 6),
                        Text('Kuis',
                            style: AppText.label(12,
                                color: AppColors.blueDark)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => AuthGate.require(context, () {
                      if (!mounted) return;
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()));
                    }),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.white.withOpacity(0.5)),
                      ),
                      child: const Icon(Icons.person_outline_rounded,
                          color: AppColors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _NavLabel extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLabel(this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(label,
              style: AppText.label(13, color: AppColors.white)
                  .copyWith(fontWeight: FontWeight.w400)),
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// QUICK ACCESS
// ════════════════════════════════════════════════════════════════════════════════
class _QuickAccessSection extends StatelessWidget {
  final VoidCallback onWisata, onKuliner, onBudaya, onBerita, onLokasi, onKuis;
  const _QuickAccessSection({
    required this.onWisata, required this.onKuliner,
    required this.onBudaya, required this.onBerita,
    required this.onLokasi, required this.onKuis,
  });

  @override 
  Widget build(BuildContext context) {
    final items = [
      _QA(Icons.explore_rounded,     'Wisata',  onWisata,  const Color.fromARGB(255, 4, 31, 106)),
      _QA(Icons.restaurant_rounded,  'Kuliner', onKuliner, const Color.fromARGB(255, 4, 31, 106)),
      _QA(Icons.museum_rounded,      'Budaya',  onBudaya,  const Color.fromARGB(255, 4, 31, 106)),
      _QA(Icons.article_rounded,     'Berita',  onBerita,  const Color.fromARGB(255, 4, 31, 106)),
      _QA(Icons.location_on_rounded, 'Lokasi',  onLokasi,  const Color.fromARGB(255, 4, 31, 106)),
    ];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jelajahi Cibarusah', style: AppText.heading(15)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.map((item) => GestureDetector(
              onTap: item.onTap,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 58,
                child: Column(
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(item.icon, color: item.color, size: 25),
                    ),
                    const SizedBox(height: 6),
                    Text(item.label,
                        style: AppText.body(10, color: AppColors.grey700)
                            .copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}

class _QA {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _QA(this.icon, this.label, this.onTap, this.color);
}

// ════════════════════════════════════════════════════════════════════════════════
// MODERN BOTTOM NAV
// ════════════════════════════════════════════════════════════════════════════════
class _ModernBottomNav extends StatelessWidget {
  final int selected;
  final void Function(int) onTap;
  const _ModernBottomNav({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.blueDark, AppColors.blueDeep],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.blueDark.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded,
                  label: 'Home', isActive: selected == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.quiz_outlined, activeIcon: Icons.quiz_rounded,
                  label: 'Kuis', isActive: selected == 1, onTap: () => onTap(1)),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(
                            color: AppColors.gold.withOpacity(0.5),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          )],
                        ),
                        child: const Icon(Icons.add_location_alt_rounded,
                            color: AppColors.blueDark, size: 22),
                      ),
                      const SizedBox(height: 3),
                      Text('Check-in',
                          style: AppText.body(8, color: AppColors.white)
                              .copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              _NavItem(icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profil', isActive: selected == 3, onTap: () => onTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon, required this.activeIcon,
    required this.label, required this.isActive, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.white.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.white : AppColors.white.withOpacity(0.45),
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(label, style: AppText.body(9).copyWith(
                color: isActive ? AppColors.white : AppColors.white.withOpacity(0.4),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              )),
            ],
          ),
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// HERO
// ════════════════════════════════════════════════════════════════════════════════
class _HeroSection extends StatelessWidget {
  final VoidCallback onJelajahi;
  const _HeroSection({super.key, required this.onJelajahi});

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    final h = MediaQuery.of(context).size.height * (mobile ? 0.72 : 0.88);
    return SizedBox(
      height: h,
      child: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/images/image1.png', fit: BoxFit.cover),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x220A1F44),
                Color(0xAA1440A0),
                Color(0xEE0A1F44),
              ],
            ),
          ),
        ),
        SafeArea(
          child: CW(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text('Tjibarusa',
                    style: AppText.display(mobile ? 52 : 72,
                        color: AppColors.white))
                    .animate().fadeIn(duration: 700.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 6),
                Text('KABUPATEN BEKASI',
                    style: AppText.caps(
                        color: AppColors.white.withOpacity(0.72)))
                    .animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 4),
                Text('Wilujeung Sumping',
                    style: AppText.script(size: 26,
                        color: AppColors.white.withOpacity(0.85)))
                    .animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 14),
                SizedBox(
                  width: mobile ? double.infinity : 420,
                  child: Text(
                    'Cibarusah adalah perpaduan harmonis antara sejarah, budaya, '
                    'alam, dan semangat masyarakat lokal.',
                    style: AppText.body(14,
                        color: AppColors.white.withOpacity(0.80)),
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onJelajahi,
                  icon: const Icon(Icons.explore_rounded, size: 16),
                  label: const Text('Jelajahi Cibarusah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.blueDeep,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// TERITORIAL (dengan gambar motif sebagai aksen, bukan lingkaran)
// ════════════════════════════════════════════════════════════════════════════════
class _TeritoralSection extends StatelessWidget {
  const _TeritoralSection({super.key});

  @override
  Widget build(BuildContext context) =>
      CW(child: R.isMobile(context) ? _mobile(context) : _desktop(context));

  Widget _desktop(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: CibarusahMapWidget(height: 320)),
          const SizedBox(width: 56),
          Expanded(child: _text(context)),
          const SizedBox(width: 24),
          // Ganti _deco() dengan gambar motif
          SizedBox(
            width: 120,
            height: 120,
            child: Image.asset(
              'assets/images/motif.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      );

  Widget _mobile(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CibarusahMapWidget(height: 220),
          const SizedBox(height: 28),
          _text(context),
          // Ganti _deco(size: 80) dengan gambar motif kecil
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                'assets/images/motif.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      );

  Widget _text(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 4, height: 24,
              decoration: BoxDecoration(
                color: AppColors.blueDeep,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text('WILAYAH', style: AppText.caps(
                size: 11, color: AppColors.blueLight)),
          ]),
          const SizedBox(height: 10),
          const SectionHeading('Teritorial\nCibarusah'),
          const SizedBox(height: 14),
          Text(
            'Cibarusah merupakan salah satu kecamatan di Kabupaten Bekasi '
            'yang terletak di wilayah Provinsi Jawa Barat dengan karakteristik '
            'geografis yang didominasi oleh perbukitan, area persawahan, dan aliran sungai.',
            style: AppText.body(15),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _StatChip(icon: Icons.terrain_rounded, label: 'Perbukitan'),
              _StatChip(icon: Icons.grass_rounded, label: 'Persawahan'),
              _StatChip(icon: Icons.water_rounded, label: 'Aliran Sungai'),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => launchUrl(
                Uri.parse('https://maps.google.com/?q=Cibarusah+Bekasi')),
            icon: const Icon(Icons.map_rounded, size: 16),
            label: const Text('Jelajahi Maps'),
          ),
        ],
      );
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.blueGhost,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.bluePastel),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: AppColors.blueDeep),
          const SizedBox(width: 5),
          Text(label,
              style: AppText.label(12, color: AppColors.blueDeep)),
        ]),
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// SEJARAH & BUDAYA
// ════════════════════════════════════════════════════════════════════════════════
class _SejarahBudayaSection extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;
  final void Function(BudayaModel) onBaca;
  final VoidCallback onKuis;
  const _SejarahBudayaSection({
    super.key, required this.selected, required this.onSelect,
    required this.onBaca, required this.onKuis,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    final items = DummyData.budaya;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blueDark, AppColors.blueDeep],
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: R.hp(context)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: mobile ? _mobile(items) : _desktop(items),
        ),
      ),
    );
  }

  Widget _desktop(List<BudayaModel> items) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _left(items)),
          const SizedBox(width: 48),
          SizedBox(width: 320,
              child: Column(children: [
                _img(items[selected]),
                const SizedBox(height: 16),
                _kuisCard(),
              ])),
        ],
      );

  Widget _mobile(List<BudayaModel> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _left(items),
          const SizedBox(height: 24),
          _img(items[selected]),
          const SizedBox(height: 16),
          _kuisCard(),
        ],
      );

  Widget _left(List<BudayaModel> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sejarah &\nBudaya',
              style: AppText.display(32, color: AppColors.white)),
          const SizedBox(height: 28),
          ...items.asMap().entries.map((e) => _AccordionRow(
                item: e.value,
                open: selected == e.key,
                onTap: () => onSelect(e.key),
                onBaca: () => onBaca(e.value),
              )),
        ],
      );

  Widget _img(BudayaModel item) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: NetImg(item.imageUrl, h: 200, w: double.infinity),
      );

  Widget _kuisCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.blueLight.withOpacity(0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.quiz_rounded, color: AppColors.gold, size: 16),
            const SizedBox(width: 8),
            Text('Kuis Pengetahuan',
                style: AppText.heading(14, color: AppColors.white)),
          ]),
          const SizedBox(height: 8),
          Text('Ikuti kuis interaktif dan dapatkan lencana "Penjaga Sejarah".',
              style: AppText.body(12,
                  color: AppColors.white.withOpacity(0.72))),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onKuis,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.blueDark,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Mulai Kuis'),
          ),
        ]),
      );
}

class _AccordionRow extends StatelessWidget {
  final BudayaModel item;
  final bool open;
  final VoidCallback onTap, onBaca;
  const _AccordionRow({
    required this.item, required this.open,
    required this.onTap, required this.onBaca,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: open ? AppColors.gold : AppColors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(100),
                    color: open ? AppColors.gold.withOpacity(0.15) : Colors.transparent,
                  ),
                  child: Text(item.name,
                      style: AppText.label(12,
                          color: open ? AppColors.gold : AppColors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Divider(color: AppColors.white.withOpacity(0.2))),
              ]),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: open
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.shortDesc,
                            style: AppText.body(13,
                                color: AppColors.white.withOpacity(0.82))),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: onBaca,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            side: BorderSide(color: AppColors.white.withOpacity(0.4)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          ),
                          child: const Text('Baca'),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// WISATA
// ════════════════════════════════════════════════════════════════════════════════
class _WisataSection extends StatelessWidget {
  final void Function(WisataModel) onTap;
  const _WisataSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cols = R.val(context, mobile: 1, tablet: 2, desktop: 3);
    return CW(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Expanded(child: SectionHeading('Rekomendasi Wisata')),
          TextButton.icon(
            onPressed: () {
              // TODO: Navigasi ke halaman semua wisata
            },
            icon: const Icon(Icons.arrow_forward_rounded, size: 15),
            label: const Text('Lihat Semua'),
          ),
        ]),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: cols == 1 ? 1.5 : 0.85,
          ),
          itemCount: DummyData.wisata.length,
          itemBuilder: (_, i) =>
              _WisataCard(DummyData.wisata[i], onTap: onTap),
        ),
      ],
    ));
  }
}

class _WisataCard extends StatelessWidget {
  final WisataModel w;
  final void Function(WisataModel) onTap;
  const _WisataCard(this.w, {required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onTap(w),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
                color: AppColors.blueDeep.withOpacity(0.08),
                blurRadius: 16, offset: const Offset(0, 4))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Stack(fit: StackFit.expand, children: [
                NetImg(w.imageUrl),
                Positioned(top: 10, left: 10,
                  child: PillTag(w.category,
                      bg: AppColors.blueDeep.withOpacity(0.80),
                      textColor: AppColors.white)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(w.name, style: AppText.heading(14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.location_on_outlined,
                      size: 12, color: AppColors.blueLight),
                  const SizedBox(width: 2),
                  Expanded(child: Text(w.location, style: AppText.body(11),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 7),
                Row(children: [
                  StarRating(w.rating),
                  const Spacer(),
                ]),
              ]),
            ),
          ]),
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// KULINER
// ════════════════════════════════════════════════════════════════════════════════
class _KulinerSection extends StatelessWidget {
  final void Function(KulinerModel) onTap;
  const _KulinerSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    return Container(
      color: AppColors.blueGhost,
      padding: EdgeInsets.symmetric(vertical: 56, horizontal: R.hp(context)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: SectionHeading('Kuliner Khas')),
              TextButton.icon(
                onPressed: () {
                  // TODO: Navigasi ke halaman semua kuliner
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                label: const Text('Lihat Semua'),
              ),
            ]),
            const SizedBox(height: 20),
            mobile
                ? Column(children: DummyData.kuliner
                      .map((k) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _KulinerCard(k, onTap: onTap)))
                      .toList())
                : Row(children: DummyData.kuliner
                      .map((k) => Expanded(child: Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _KulinerCard(k, onTap: onTap))))
                      .toList()),
          ]),
        ),
      ),
    );
  }
}

class _KulinerCard extends StatelessWidget {
  final KulinerModel k;
  final void Function(KulinerModel) onTap;
  const _KulinerCard(this.k, {required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onTap(k),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
                color: AppColors.blueDeep.withOpacity(0.06),
                blurRadius: 12, offset: const Offset(0, 4))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            NetImg(k.imageUrl, h: 170, w: double.infinity),
            Padding(padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(k.name, style: AppText.heading(14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text(k.shortDesc, style: AppText.body(12),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 9),
                Row(children: [
                  Icon(Icons.payments_outlined,
                      size: 13, color: AppColors.blueLight),
                  const SizedBox(width: 4),
                  Text(k.priceRange,
                      style: AppText.label(12, color: AppColors.blueDeep)),
                ]),
              ]),
            ),
          ]),
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// BERITA
// ════════════════════════════════════════════════════════════════════════════════
class _BeritaSection extends StatelessWidget {
  final void Function(BeritaModel) onTap;
  const _BeritaSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    return CW(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Expanded(child: SectionHeading('Berita & Event')),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.arrow_forward_rounded, size: 15),
            label: const Text('Lihat Semua'),
          ),
        ]),
        const SizedBox(height: 20),
        mobile
            ? Column(children: DummyData.berita
                  .map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _BeritaCard(b, onTap: onTap)))
                  .toList())
            : Row(children: DummyData.berita
                  .map((b) => Expanded(child: Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: _BeritaCard(b, onTap: onTap))))
                  .toList()),
      ],
    ));
  }
}

class _BeritaCard extends StatelessWidget {
  final BeritaModel b;
  final void Function(BeritaModel) onTap;
  const _BeritaCard(this.b, {required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onTap(b),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
                color: AppColors.blueDeep.withOpacity(0.06),
                blurRadius: 10, offset: const Offset(0, 3))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16)),
              child: NetImg(b.imageUrl, w: 100, h: 100),
            ),
            Expanded(child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                PillTag(b.category,
                    bg: AppColors.blueGhost,
                    textColor: AppColors.blueDeep),
                const SizedBox(height: 7),
                Text(b.title, style: AppText.heading(13),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text('${b.publishedAt.day}/${b.publishedAt.month}/${b.publishedAt.year}',
                    style: AppText.body(10)),
              ]),
            )),
          ]),
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// FOOTER
// ════════════════════════════════════════════════════════════════════════════════
class _FooterSection extends StatelessWidget {
  final void Function(int) onNavTap;
  const _FooterSection({required this.onNavTap});

  static const _links = [
    ('Beranda', 0), ('Lokasi', 1), ('Tentang', 2),
    ('Wisata', 3), ('Kuliner', 4), ('Berita', 5),
  ];

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.blueDark, AppColors.blueDeep],
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 48, horizontal: R.hp(context)),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(children: [
              Text('Tjibarusa',
                  style: AppText.display(28, color: AppColors.white)),
              const SizedBox(height: 4),
              Text('KABUPATEN BEKASI',
                  style: AppText.caps(size: 10, color: AppColors.white.withOpacity(0.5))),
              const SizedBox(height: 24),
              Wrap(
                spacing: 24, runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _links.map((e) => GestureDetector(
                      onTap: () => onNavTap(e.$2),
                      child: Text(e.$1,
                          style: AppText.label(13, color: AppColors.white)
                              .copyWith(fontWeight: FontWeight.w400)),
                    )).toList(),
              ),
              const SizedBox(height: 24),
              Divider(color: AppColors.white.withOpacity(0.1)),
              const SizedBox(height: 16),
              Text('© 2026 Tjibarusa.',
                  style: AppText.body(12, color: AppColors.white.withOpacity(0.45)),
                  textAlign: TextAlign.center),
            ]),
          ),
        ),
      );
}