// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db   = FirebaseFirestore.instance;

  // ── Stream user state ────────────────────────────────────────────────────────
  static Stream<User?> get userStream => _auth.authStateChanges();
  static User?         get currentUser => _auth.currentUser;
  static bool          get isLoggedIn  => _auth.currentUser != null;

  // ── Register ─────────────────────────────────────────────────────────────────
  static Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw FirebaseAuthException(
              code: 'network-request-failed',
            ),
          );

      await cred.user?.updateDisplayName(name.trim());

      // Simpan profil ke Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'name':       name.trim(),
        'email':      email.trim(),
        'createdAt':  FieldValue.serverTimestamp(),
        'kuisScore':  0,
        'kuisPlayed': 0,
        'checkIns':   [],
        'bestScores': {'0': 0, '1': 0, '2': 0},
      });

      return null; // null = sukses
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    } catch (e) {
      // Catch semua error lain (timeout, network, dsb)
      return 'Terjadi kesalahan. Periksa koneksi internet kamu.';
    }
  }

  // ── Login ────────────────────────────────────────────────────────────────────
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw FirebaseAuthException(
              code: 'network-request-failed',
            ),
          );
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    } catch (e) {
      return 'Terjadi kesalahan. Periksa koneksi internet kamu.';
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────────
  static Future<void> logout() => _auth.signOut();

  // ── Save kuis result ke Firestore ────────────────────────────────────────────
  static Future<void> saveKuisResult(int levelIndex, int score) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    final ref  = _db.collection('users').doc(uid);
    final snap = await ref.get();
    final data = snap.data() ?? {};

    final bestScores   = Map<String, dynamic>.from(data['bestScores'] ?? {});
    final currentBest  = (bestScores['$levelIndex'] ?? 0) as int;

    await ref.update({
      'kuisPlayed':             FieldValue.increment(1),
      'kuisScore':              FieldValue.increment(score),
      'bestScores.$levelIndex': score > currentBest ? score : currentBest,
    });
  }

  // ── Save check-in ke Firestore ───────────────────────────────────────────────
  static Future<void> saveCheckIn(String wisataId, String wisataName) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).update({
      'checkIns': FieldValue.arrayUnion([{
        'wisataId':   wisataId,
        'wisataName': wisataName,
        'date':       FieldValue.serverTimestamp(),
      }]),
    });
  }

  // ── Get user data ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUserData() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    final snap = await _db.collection('users').doc(uid).get();
    return snap.data();
  }

  // ── Error messages Indonesia ──────────────────────────────────────────────────
  static String _errorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':   return 'Email sudah terdaftar.';
      case 'invalid-email':          return 'Format email tidak valid.';
      case 'weak-password':          return 'Password minimal 6 karakter.';
      case 'user-not-found':         return 'Email tidak ditemukan.';
      case 'wrong-password':         return 'Password salah.';
      case 'invalid-credential':     return 'Email atau password salah.';
      case 'too-many-requests':      return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed': return 'Tidak ada koneksi internet.';
      default:                       return 'Terjadi kesalahan ($code). Coba lagi.';
    }
  }
}