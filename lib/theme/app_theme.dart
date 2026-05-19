// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Blue Gradient Palette ─────────────────────────────────────────────────
  static const Color blueDark   = Color(0xFF0A1F44);  // biru dongker
  static const Color blueDeep   = Color(0xFF1440A0);  // biru royal
  static const Color blueMid    = Color(0xFF2563EB);  // biru terang
  static const Color blueLight  = Color(0xFF60A5FA);  // biru muda
  static const Color bluePastel = Color(0xFFBFDBFE);  // biru pastel
  static const Color blueGhost  = Color(0xFFEFF6FF);  // biru sangat muda

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color gold       = Color(0xFFF59E0B);  // amber/gold
  static const Color goldLight  = Color(0xFFFCD34D);  // gold muda
  static const Color teal       = Color(0xFF0EA5E9);  // sky blue accent
  static const Color purple     = Color(0xFF8B5CF6);  // ungu accent

  // ── Neutral ───────────────────────────────────────────────────────────────
  static const Color white      = Color(0xFFFFFFFF);
  static const Color offWhite   = Color(0xFFF8FAFF);  // putih kebiruan
  static const Color grey100    = Color(0xFFF1F5F9);
  static const Color grey200    = Color(0xFFE2E8F0);
  static const Color grey300    = Color(0xFFCBD5E1);
  static const Color grey400    = Color(0xFF94A3B8);
  static const Color grey500    = Color(0xFF64748B);
  static const Color grey600    = Color(0xFF475569);
  static const Color grey700    = Color(0xFF334155);
  static const Color grey800    = Color(0xFF1E293B);
  static const Color grey900    = Color(0xFF0F172A);

  // ── Gradients ─────────────────────────────────────────────────────────────

  // Gradient utama — biru gelap ke terang
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blueDark, blueDeep, blueMid],
  );

  // Hero section — transparan ke biru gelap (bawah)
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x000A1F44),
      Color(0x881440A0),
      Color(0xDD0A1F44),
    ],
  );

  // Card / section dark background
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blueDark, blueDeep],
  );

  // Soft blue background — untuk section terang
  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blueGhost, Color(0xFFDCEFFE)],
  );

  // Navbar / bottom bar gradient
  static const LinearGradient navbarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blueDeep, blueMid],
  );

  // Alias kompatibilitas dengan kode lama
  static const Color navyDeep  = blueDark;
  static const Color navyMid   = blueDeep;
  static const Color navyLight = blueMid;
  static const Color cream     = blueGhost;
}

// ─── Text Styles ──────────────────────────────────────────────────────────────
class AppText {
  static TextStyle display(double size,
      {Color color = AppColors.blueDark}) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -0.5,
    );
  }

  static TextStyle heading(double size,
      {Color color = AppColors.blueDark}) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle label(double size,
      {Color color = AppColors.grey600}) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle body(double size,
      {Color color = AppColors.grey700}) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.55,
    );
  }

  static TextStyle caps(
      {double size = 12, Color color = AppColors.grey500}) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 1.4,
    );
  }

  static TextStyle script(
      {double size = 24, Color color = AppColors.white}) {
    return GoogleFonts.dancingScript(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }
}

// ─── Theme ────────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.blueDeep,
    scaffoldBackgroundColor: AppColors.offWhite,
    colorScheme: const ColorScheme.light(
      primary:   AppColors.blueDeep,
      secondary: AppColors.teal,
      tertiary:  AppColors.gold,
      surface:   AppColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.blueDeep,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blueDeep,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.blueDeep,
        side: const BorderSide(color: AppColors.blueDeep),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.blueMid,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.blueMid, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
    ),
  );
}