// lib/screens/detail_batik_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../widgets/shared_widgets.dart';
import 'kuis_screen.dart';

const _batikText =
    'Batik khas Cibarusah menjadi salah satu bentuk pelestarian budaya lokal yang '
    'mengangkat identitas daerah melalui berbagai motif bernilai sejarah dan alam. '
    'Salah satu motif yang cukup dikenal adalah motif ikan, yang terinspirasi dari '
    'kehidupan masyarakat Cibarusah yang dekat dengan aliran sungai dan kawasan '
    'perairan. Dalam budaya batik, ikan sering dimaknai sebagai simbol keberlimpahan, '
    'ketahanan hidup, serta harapan akan kesejahteraan. Motif tersebut kemudian '
    'dipadukan dengan ornamen tumbuhan dan pola khas batik Sunda sehingga menghasilkan '
    'desain yang unik dan memiliki ciri khas daerah.\n\n'
    'Perkembangan batik Cibarusah juga menjadi upaya memperkenalkan sejarah dan '
    'kekayaan budaya Bekasi kepada masyarakat luas. Selain motif ikan, batik khas '
    'Cibarusah turut mengangkat unsur sejarah lokal dan kehidupan masyarakat sebagai '
    'identitas visual daerah. Kehadiran batik ini diharapkan mampu menjadi simbol '
    'budaya Kabupaten Bekasi sekaligus memperkuat nilai tradisi lokal di tengah '
    'perkembangan zaman modern. Filosofi motif ikan sendiri menggambarkan keluwesan, '
    'semangat bertahan hidup, dan keharmonisan manusia dengan alam, sehingga tidak '
    'hanya memiliki nilai estetika tetapi juga makna budaya yang mendalam.';

class DetailBatikScreen extends StatefulWidget {
  final BudayaModel budaya;
  const DetailBatikScreen({super.key, required this.budaya});

  @override
  State<DetailBatikScreen> createState() => _DetailBatikScreenState();
}

class _DetailBatikScreenState extends State<DetailBatikScreen> {

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Hero ──────────────────────────────────────────────────────
            Stack(
              children: [
                // Gambar hero
                SizedBox(
                  height: screenH * (mobile ? 0.45 : 0.52),
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/imagebatik1.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.navyDeep, AppColors.navyMid],
                        ),
                      ),
                    ),
                  ),
                ),

                // Overlay gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.navyDeep.withOpacity(0.45),
                          AppColors.navyDeep.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                ),

                // Curved bottom putih
                Positioned(
                  bottom: -1, left: 0, right: 0,
                  child: Container(
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                  ),
                ),

                // Back button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _BackBtn(onTap: () => Navigator.pop(context)),
                  ),
                ),

                // Judul di atas hero
                Positioned(
                  bottom: 42, left: 24, right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color: AppColors.gold.withOpacity(0.5)),
                        ),
                        child: Text(
                          widget.budaya.type.toUpperCase(),
                          style: AppText.caps(
                              size: 10, color: AppColors.gold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.budaya.name.toUpperCase(),
                        style: AppText.display(
                            mobile ? 28 : 38, color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Content ───────────────────────────────────────────────────
            CW(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ── Row: deskripsi singkat + tombol audio ────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.budaya.shortDesc,
                          style: AppText.body(14, color: AppColors.grey700)
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Layout desktop/mobile ─────────────────────────────────
                  mobile ? _buildMobile() : _buildDesktop(),

                  const SizedBox(height: 40),

                  // ── Kuis card ─────────────────────────────────────────────
                  _KuisCard(context: context),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktop() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/imagebatik2.png',
              width: 300,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 300, height: 280,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.navyDeep, AppColors.navyLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.palette_rounded,
                    color: AppColors.white, size: 64),
              ),
            ),
          ),
          const SizedBox(width: 40),
          Expanded(child: _textContent()),
        ],
      );

  Widget _buildMobile() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/imagebatik2.png',
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.navyDeep, AppColors.navyLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.palette_rounded,
                    color: AppColors.white, size: 64),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _textContent(),
        ],
      );

  Widget _textContent() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4, width: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.navyMid, Color(0xFF60A5FA)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _batikText,
            style: AppText.body(14, color: AppColors.grey700)
                .copyWith(height: 1.85),
          ),
        ],
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// KUIS CARD
// ════════════════════════════════════════════════════════════════════════════════
class _KuisCard extends StatelessWidget {
  final BuildContext context;
  const _KuisCard({required this.context});

  @override
  Widget build(BuildContext _) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navyDeep, AppColors.navyMid],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.navyDeep.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.quiz_rounded, color: AppColors.white, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kuis Pengetahuan',
                      style: AppText.heading(16, color: AppColors.white)),
                  const SizedBox(height: 4),
                  Text(
                    'Uji pemahamanmu tentang budaya Cibarusah dan raih lencana eksklusif!',
                    style: AppText.body(12,
                        color: AppColors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KuisScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text('Mulai',
                    style: AppText.label(13, color: AppColors.navyDeep)),
              ),
            ),
          ],
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// BACK BUTTON
// ════════════════════════════════════════════════════════════════════════════════
class _BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBtn({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.arrow_back_ios_rounded,
                size: 13, color: AppColors.navyDeep),
            const SizedBox(width: 4),
          ]),
        ),
      );
}