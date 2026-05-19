// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  bool onboardingDone = false;
  try {
    onboardingDone = await OnboardingPrefs.isDone();
  } catch (_) {
    onboardingDone = false;
  }

  runApp(TjibarusaApp(showOnboarding: !onboardingDone));
}

class TjibarusaApp extends StatelessWidget {
  final bool showOnboarding;
  const TjibarusaApp({super.key, this.showOnboarding = true});

  @override
  Widget build(BuildContext context) {
    // FIX: hanya 2 kondisi —
    // 1. Belum pernah buka → Onboarding → Home
    // 2. Sudah onboarding (login atau tidak) → langsung Home
    //    Login hanya diminta saat tap fitur yang butuh login (AuthGate)
    return MaterialApp(
      title: 'Tjibarusa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}