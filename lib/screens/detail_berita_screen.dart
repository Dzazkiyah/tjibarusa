// lib/screens/detail_berita_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../widgets/shared_widgets.dart';

class DetailBeritaScreen extends StatelessWidget {
  final BeritaModel berita;
  const DetailBeritaScreen({super.key, required this.berita});

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    final b = berita;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          // ── Hero ─────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: mobile ? 260 : 380,
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
                padding: const EdgeInsets.only(right: 12, top: 10),
                child: Container(
                  width: 36, height: 36,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                NetImg(b.imageUrl),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.navyDeep.withOpacity(0.65),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20, left: 20,
                  child: PillTag(b.category,
                      bg: AppColors.navyDeep.withOpacity(0.75),
                      textColor: AppColors.white),
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
                        _mainContent(b, context),
                        const SizedBox(height: 32),
                        _sidebar(b, context),
                        const SizedBox(height: 20),
                      ])
                    : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(flex: 6, child: _mainContent(b, context)),
                        const SizedBox(width: 56),
                        Expanded(flex: 4, child: _sidebar(b, context)),
                      ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Main Content ───────────────────────────────────────────────────────────
  Widget _mainContent(BeritaModel b, BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            PillTag(b.category, bg: AppColors.navyDeep.withOpacity(0.08)),
            const SizedBox(width: 10),
            const Icon(Icons.calendar_today_outlined,
                size: 13, color: AppColors.grey500),
            const SizedBox(width: 4),
            Text(
              '${b.publishedAt.day}/${b.publishedAt.month}/${b.publishedAt.year}',
              style: AppText.body(12),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.person_outline_rounded,
                size: 13, color: AppColors.grey500),
            const SizedBox(width: 4),
            Text(b.author, style: AppText.body(12)),
          ]),
          const SizedBox(height: 16),

          Text(b.title,
              style: GoogleFonts.playfairDisplay(
                  fontSize: R.isMobile(context) ? 24 : 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDeep,
                  height: 1.3)),
          const SizedBox(height: 12),

          Text(b.summary,
              style: AppText.body(16).copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),

          const Divider(),
          const SizedBox(height: 20),

          Text(b.fullContent, style: AppText.body(15)),
          const SizedBox(height: 28),
        ],
      );

  // ── Sidebar ────────────────────────────────────────────────────────────────
  Widget _sidebar(BeritaModel b, BuildContext context) {
    final related =
        DummyData.berita.where((item) => item.id != b.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Berita Lainnya', style: AppText.heading(16)),
        const SizedBox(height: 14),
        if (related.isEmpty)
          Text('Belum ada berita lainnya.', style: AppText.body(13))
        else
          ...related.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(
                          builder: (_) => DetailBeritaScreen(berita: item))),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(
                        color: AppColors.navyDeep.withOpacity(0.06),
                        blurRadius: 10, offset: const Offset(0, 3),
                      )],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(children: [
                      SizedBox(
                        width: 90, height: 90,
                        child: NetImg(item.imageUrl),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PillTag(item.category,
                                  bg: AppColors.navyDeep.withOpacity(0.07)),
                              const SizedBox(height: 6),
                              Text(item.title,
                                  style: AppText.heading(12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 5),
                              Text(
                                '${item.publishedAt.day}/${item.publishedAt.month}/${item.publishedAt.year}',
                                style: AppText.body(10),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.chevron_right_rounded,
                            color: AppColors.grey500, size: 20),
                      ),
                    ]),
                  ),
                ),
              )),
      ],
    );
  }
}