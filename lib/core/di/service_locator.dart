// lib/core/di/service_locator.dart
// Wires all services and makes them available to the Provider tree.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/remote/auth_service.dart';
import '../../data/datasources/remote/sync_service.dart';
import '../../data/datasources/remote/notification_service.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/products_provider.dart';
import '../../presentation/providers/offers_provider.dart';
import '../../presentation/providers/cart_provider.dart';

/// Holds all singletons after [ServiceLocator.init] is called.
class ServiceLocator {
  ServiceLocator._();

  // ── Firebase singletons ──
  static late FirebaseAuth      firebaseAuth;
  static late FirebaseFirestore firestore;
  static late FirebaseMessaging messaging;

  // ── Service singletons ──
  static late AuthService         authService;
  static late SyncService         syncService;
  static late NotificationService notificationService;

  // ── Provider factories ──
  static late AuthProvider     authProvider;
  static late ProductsProvider productsProvider;
  static late OffersProvider   offersProvider;
  static late CartProvider     cartProvider;

  /// Call once from main() after Firebase.initializeApp()
  static Future<void> init() async {
    // ── Firebase ────────────────────────────────────────────────────────────
    firebaseAuth = FirebaseAuth.instance;
    firestore    = FirebaseFirestore.instance;
    messaging    = FirebaseMessaging.instance;

    // ── Shared Preferences ───────────────────────────────────────────────────
    final prefs = await SharedPreferences.getInstance();

    // ── Local Notifications ──────────────────────────────────────────────────
    final localNotifications = FlutterLocalNotificationsPlugin();

    // ── Services ────────────────────────────────────────────────────────────
    authService = AuthService(
      auth: firebaseAuth,
      googleSignIn: GoogleSignIn(
        scopes: ['email', 'profile'],
      ),
      firestore: firestore,
    );

    syncService = SyncService(
      firestore: firestore,
      prefs: prefs,
    );

    notificationService = NotificationService(
      messaging:          messaging,
      firestore:          firestore,
      localNotifications: localNotifications,
    );

    // ── Providers ────────────────────────────────────────────────────────────
    authProvider     = AuthProvider(authService: authService);
    productsProvider = ProductsProvider(syncService: syncService);
    offersProvider   = OffersProvider(
      syncService: syncService,
      firestore:   firestore,
    );
    cartProvider     = CartProvider();

    // ── Start sync ───────────────────────────────────────────────────────────
    await syncService.initialize();
  }
}
