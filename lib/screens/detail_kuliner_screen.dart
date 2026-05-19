// lib/screens/detail_kuliner_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../widgets/shared_widgets.dart';

class DetailKulinerScreen extends StatefulWidget {
  final KulinerModel kuliner;
  const DetailKulinerScreen({super.key, required this.kuliner});

  @override
  State<DetailKulinerScreen> createState() => _DetailKulinerScreenState();
}

class _DetailKulinerScreenState extends State<DetailKulinerScreen> {
  bool _isFav = false;
  KulinerModel get k => widget.kuliner;

  void _openMaps() async {
    final url = Uri.parse(k.mapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          // ── Hero ─────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: mobile ? 280 : 400,
            pinned: true,
            backgroundColor: AppColors.navyDeep,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.arrow_back_ios_rounded,
                      size: 14, color: AppColors.navyDeep),
                ),
              ),
            ),
            leadingWidth: 50,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _isFav = !_isFav),
                  child: Container(
                    width: 36, height: 36,
                    margin: const EdgeInsets.only(top: 10),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                NetImg(k.imageUrl),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.navyDeep.withOpacity(0.55)],
                    ),
                  ),
                ),
              ]),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: CW(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: mobile ? 28 : 48),
                child: mobile
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _mainInfo(mobile),
                        const SizedBox(height: 28),
                        _sidePanel(),
                        const SizedBox(height: 20),
                      ])
                    : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(flex: 6, child: _mainInfo(mobile)),
                        const SizedBox(width: 56),
                        Expanded(flex: 4, child: _sidePanel()),
                      ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Main Info ──────────────────────────────────────────────────────────────
  Widget _mainInfo(bool mobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PillTag(k.origin, bg: AppColors.navyDeep.withOpacity(0.08)),
          const SizedBox(height: 12),

          Text(k.name,
              style: GoogleFonts.playfairDisplay(
                  fontSize: mobile ? 26 : 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDeep)),
          const SizedBox(height: 12),

          Row(children: [
            const Icon(Icons.payments_outlined, size: 16, color: AppColors.navyMid),
            const SizedBox(width: 6),
            Text(k.priceRange,
                style: AppText.label(13, color: AppColors.navyMid)
                    .copyWith(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 20),

          Text(k.shortDesc,
              style: AppText.body(16).copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 14),

          Text(k.fullDesc, style: AppText.body(15)),
          const SizedBox(height: 28),

          Wrap(spacing: 12, runSpacing: 12, children: [
            ElevatedButton.icon(
              onPressed: _openMaps,
              icon: const Icon(Icons.map_outlined, size: 16),
              label: const Text('Cari di Maps'),
            ),
          ]),
        ],
      );

  // ── Side Panel ─────────────────────────────────────────────────────────────
  Widget _sidePanel() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (k.whereToFind.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                  color: AppColors.navyDeep.withOpacity(0.07),
                  blurRadius: 16, offset: const Offset(0, 4),
                )],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: AppColors.navyMid),
                    const SizedBox(width: 8),
                    Text('Dimana Menemukannya', style: AppText.heading(14)),
                  ]),
                  const SizedBox(height: 14),
                  ...k.whereToFind.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22, height: 22,
                              decoration: const BoxDecoration(
                                  color: AppColors.navyDeep,
                                  shape: BoxShape.circle),
                              child: Center(
                                child: Text('${e.key + 1}',
                                    style: AppText.body(10, color: AppColors.white)
                                        .copyWith(fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(e.value, style: AppText.body(13))),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.navyDeep.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.navyDeep.withOpacity(0.08)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.payments_outlined, size: 16, color: AppColors.navyMid),
                const SizedBox(width: 8),
                Text('Kisaran Harga', style: AppText.heading(14)),
              ]),
              const SizedBox(height: 10),
              Text(k.priceRange,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyDeep)),
              const SizedBox(height: 4),
              Text('Harga dapat bervariasi tergantung warung',
                  style: AppText.body(12)),
            ]),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.navyDeep.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.navyDeep.withOpacity(0.08)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: AppColors.navyMid, size: 16),
                const SizedBox(width: 8),
                Text('Tips Menikmati', style: AppText.heading(13)),
              ]),
              const SizedBox(height: 10),
              Text(
                '• Nikmati selagi panas untuk rasa terbaik\n'
                '• Cocok dimakan pagi dan siang hari',
                style: AppText.body(12),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          _relatedSection(),
        ],
      );

  Widget _relatedSection() {
    final related =
        DummyData.kuliner.where((item) => item.id != k.id).take(2).toList();
    if (related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kuliner Lainnya', style: AppText.heading(15)),
        const SizedBox(height: 12),
        ...related.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(
                        builder: (_) => DetailKulinerScreen(kuliner: item))),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                      color: AppColors.navyDeep.withOpacity(0.06),
                      blurRadius: 10, offset: const Offset(0, 3),
                    )],
                  ),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: NetImg(item.imageUrl, w: 60, h: 60),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PillTag(item.origin,
                              bg: AppColors.navyDeep.withOpacity(0.07)),
                          const SizedBox(height: 4),
                          Text(item.name,
                              style: AppText.heading(13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text(item.priceRange,
                              style: AppText.label(11, color: AppColors.navyMid)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.grey500),
                  ]),
                ),
              ),
            )),
      ],
    );
  }
}