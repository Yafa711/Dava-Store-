// lib/main.dart
// App entry point: initialises Firebase, then ServiceLocator, then runs app.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/di/service_locator.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Lock orientation to portrait ─────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Status bar style ─────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:            Colors.transparent,
    statusBarIconBrightness:   Brightness.light,
    systemNavigationBarColor:  Color(0xFF18242C),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // ── حماية الإقلاع: محاولة تشغيل الخدمات دون السماح لها بإحداث كراش ──
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase initialization bypassed: $e");
  }

  try {
    await ServiceLocator.init();
  } catch (e) {
    print("ServiceLocator initialization bypassed: $e");
  }

  // ── Run ──────────────────────────────────────────────────────────────────
  runApp(const DavaStoreApp());
}
