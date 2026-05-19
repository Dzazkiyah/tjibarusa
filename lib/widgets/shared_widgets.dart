// lib/widgets/shared_widgets.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

// ─── Responsive helper ────────────────────────────────────────────────────────
class R {
  static bool isMobile(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width < 600;
  static bool isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 &&
      MediaQuery.of(ctx).size.width < 1024;
  static bool isDesktop(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 1024;

  static double hp(BuildContext ctx) => isMobile(ctx)
      ? 20
      : isTablet(ctx)
          ? 40
          : 80;

  static T val<T>(BuildContext ctx,
          {required T mobile, T? tablet, required T desktop}) =>
      isDesktop(ctx)
          ? desktop
          : isTablet(ctx)
              ? (tablet ?? desktop)
              : mobile;
}

// ─── MaxWidth content wrapper ─────────────────────────────────────────────────
class CW extends StatelessWidget {
  final Widget child;
  final double maxW;
  const CW({super.key, required this.child, this.maxW = 1200});

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: R.hp(context)),
            child: child,
          ),
        ),
      );
}

// ─── Section Heading ──────────────────────────────────────────────────────────
class SectionHeading extends StatelessWidget {
  final String title;
  final bool center;
  final Color? color;
  const SectionHeading(this.title,
      {super.key, this.center = false, this.color});

  @override
  Widget build(BuildContext context) {
    final fs = R.val<double>(context, mobile: 26, tablet: 30, desktop: 34);
    return Text(
      title,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: AppText.display(fs, color: color ?? AppColors.navyDeep),
    );
  }
}

// ─── Pill tag ─────────────────────────────────────────────────────────────────
class PillTag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;
  const PillTag(this.label,
      {super.key,
      this.bg = AppColors.grey100,
      this.textColor = AppColors.navyDeep});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(100)),
        child: Text(label, style: AppText.label(11, color: textColor)),
      );
}

// ─── Star rating ──────────────────────────────────────────────────────────────
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  const StarRating(this.rating, {super.key, this.size = 14});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            5,
            (i) => Icon(
              i < rating.floor()
                  ? Icons.star_rounded
                  : i < rating
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              size: size,
              color: i < rating ? AppColors.gold : AppColors.grey300,
            ),
          ),
          const SizedBox(width: 4),
          Text('$rating', style: AppText.body(11, color: AppColors.grey700)),
        ],
      );
}

// ─── Network/Asset image ──────────────────────────────────────────────────────
// Otomatis deteksi: kalau url mulai dengan "assets/" → pakai Image.asset
// Kalau URL biasa (http/https) → pakai CachedNetworkImage
class NetImg extends StatelessWidget {
  final String url;
  final double? w, h;
  final BoxFit fit;
  const NetImg(this.url,
      {super.key, this.w, this.h, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final isAsset = url.startsWith('assets/');

    if (isAsset) {
      return Image.asset(
        url,
        width: w,
        height: h,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: w,
      height: h,
      fit: fit,
      placeholder: (_, __) => Container(color: AppColors.grey100),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        width: w,
        height: h,
        color: AppColors.grey100,
        child: const Center(
          child: Icon(Icons.image_not_supported_rounded,
              color: AppColors.grey300, size: 32),
        ),
      );
}

// ─── Avatar circle ────────────────────────────────────────────────────────────
class Avatar extends StatelessWidget {
  final String initials;
  final double size;
  const Avatar(this.initials, {super.key, this.size = 40});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.navyDeep, AppColors.navyMid],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(initials,
            style: AppText.label(size * 0.3, color: AppColors.white)),
      );
}