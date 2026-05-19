// lib/widgets/auth_gate.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../screens/login_screen.dart';

// ════════════════════════════════════════════════════════════════════════════════
// AuthGate.require — panggil ini sebelum aksi yang butuh login
// Contoh: AuthGate.require(context, () => goToCheckin())
// ════════════════════════════════════════════════════════════════════════════════
class AuthGate {
  static void require(BuildContext context, VoidCallback onSuccess) {
    if (AuthService.isLoggedIn) {
      // Sudah login, langsung jalankan
      onSuccess();
    } else {
      // Belum login, tampilkan bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        // FIX: pakai useRootNavigator agar tidak konflik dengan nested navigator
        useRootNavigator: true,
        builder: (_) => _AuthPromptSheet(
          onSuccess: onSuccess,
          // FIX: kirim context asli (bukan context dari builder)
          // supaya Navigator.push setelah login bisa jalan di tree yang benar
          homeContext: context,
        ),
      );
    }
  }
}

// ─── Bottom sheet prompt login ────────────────────────────────────────────────
class _AuthPromptSheet extends StatelessWidget {
  final VoidCallback? onSuccess;
  final BuildContext homeContext; // context dari HomeScreen, bukan dari sheet

  const _AuthPromptSheet({
    this.onSuccess,
    required this.homeContext,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          24, 16, 24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ikon kunci
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: AppColors.navyDeep.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.navyDeep, size: 30),
            ),
            const SizedBox(height: 16),

            Text('Login Dulu Yuk!',
                style: AppText.heading(20, color: AppColors.navyDeep)),
            const SizedBox(height: 8),
            Text(
              'Fitur ini hanya tersedia untuk pengguna\nyang sudah login atau daftar.',
              style: AppText.body(13, color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Info fitur yang butuh login
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _FeatureRow(icon: Icons.add_location_alt_rounded,
                      label: 'Check-in & kumpulkan badge'),
                  const SizedBox(height: 8),
                  _FeatureRow(icon: Icons.quiz_rounded,
                      label: 'Ikuti kuis & simpan skor'),
                  const SizedBox(height: 8),
                  _FeatureRow(icon: Icons.person_rounded,
                      label: 'Kelola profil & riwayat'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol login
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 1. Tutup bottom sheet dulu
                  Navigator.of(context, rootNavigator: true).pop();

                  // 2. Push LoginScreen dari homeContext
                  //    onLoginSuccess dipanggil saat login/daftar berhasil
                  //    → lalu onSuccess (misal: buka KuisScreen) dijalankan
                  Navigator.push(
                    homeContext,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(
                        onLoginSuccess: onSuccess,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyDeep,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text('Masuk / Daftar',
                    style: AppText.heading(15, color: AppColors.white)),
              ),
            ),
            const SizedBox(height: 10),

            // Tetap di home
            TextButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
              child: Text('Nanti saja',
                  style: AppText.body(13, color: AppColors.grey500)),
            ),
          ],
        ),
      );
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: AppColors.navyDeep.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.navyDeep),
        ),
        const SizedBox(width: 10),
        Text(label, style: AppText.body(13)),
      ]);
}