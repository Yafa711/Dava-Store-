// lib/data/datasources/remote/sync_service.dart
// SyncService – pulls live Firestore updates, prunes expired offers,
// refreshes local cache, and broadcasts change events via streams.

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/offer_model.dart';
import '../../models/product_model.dart';

class SyncService {
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;

  // Stream controllers to broadcast real-time updates to UI layer
  final _offersController    = StreamController<List<OfferModel>>.broadcast();
  final _productsController  = StreamController<List<ProductModel>>.broadcast();
  final _syncStatusController = StreamController<SyncStatus>.broadcast();

  // Expose streams for providers to listen to
  Stream<List<OfferModel>>   get offersStream    => _offersController.stream;
  Stream<List<ProductModel>> get productsStream  => _productsController.stream;
  Stream<SyncStatus>         get syncStatusStream => _syncStatusController.stream;

  // Firestore real-time listeners
  StreamSubscription? _offersListener;
  StreamSubscription? _productsListener;

  Timer? _periodicSyncTimer;

  SyncService({
    required FirebaseFirestore firestore,
    required SharedPreferences prefs,
  })  : _firestore = firestore,
        _prefs     = prefs;

  // ─── Initialize Sync ─────────────────────────────────────────────────────────
  /// Starts real-time Firestore listeners and schedules periodic sync.
  Future<void> initialize() async {
    _syncStatusController.add(SyncStatus.syncing);
    await refreshData();
    _startRealTimeListeners();
    _schedulePeriodicSync();
  }

  // ─── refreshData ─────────────────────────────────────────────────────────────
  /// Main sync method:
  ///  1. Removes expired offers from Firestore (admin cleanup)
  ///  2. Fetches fresh products & offers from Firestore
  ///  3. Saves results to local SharedPreferences cache
  ///  4. Broadcasts updated data to all listeners
  Future<void> refreshData() async {
    try {
      _syncStatusController.add(SyncStatus.syncing);

      // ── Step 1: Prune expired offers ────────────────────────────────────────
      await _removeExpiredOffers();

      // ── Step 2: Fetch fresh data ─────────────────────────────────────────────
      final offers   = await _fetchActiveOffers();
      final products = await _fetchActiveProducts();

      // ── Step 3: Cache locally ────────────────────────────────────────────────
      await _cacheOffers(offers);
      await _cacheProducts(products);
      await _prefs.setInt(
        AppConstants.cacheKeyLastSync,
        DateTime.now().millisecondsSinceEpoch,
      );

      // ── Step 4: Broadcast ────────────────────────────────────────────────────
      _offersController.add(offers);
      _productsController.add(products);

      _syncStatusController.add(SyncStatus.synced);
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      // Fallback: emit cached data so app still works offline
      _emitCachedData();
    }
  }

  // ─── Remove Expired Offers ───────────────────────────────────────────────────
  /// Queries Firestore for offers whose expiry_date has passed and
  /// marks them as inactive (soft-delete to preserve history).
  Future<void> _removeExpiredOffers() async {
    final now = Timestamp.fromDate(DateTime.now());

    final expiredSnapshot = await _firestore
        .collection(AppConstants.offersCollection)
        .where('is_active', isEqualTo: true)
        .where('expiry_date', isLessThan: now)
        .get();

    if (expiredSnapshot.docs.isEmpty) return;

    // Batch update for efficiency (max 500 per batch)
    final batches = <WriteBatch>[];
    WriteBatch batch = _firestore.batch();
    int count = 0;

    for (final doc in expiredSnapshot.docs) {
      batch.update(doc.reference, {'is_active': false});
      count++;
      if (count == 500) {
        batches.add(batch);
        batch = _firestore.batch();
        count = 0;
      }
    }
    if (count > 0) batches.add(batch);

    await Future.wait(batches.map((b) => b.commit()));
  }

  // ─── Fetch Active Offers ─────────────────────────────────────────────────────
  Future<List<OfferModel>> _fetchActiveOffers() async {
    final snap = await _firestore
        .collection(AppConstants.offersCollection)
        .where('is_active', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .get();

    return snap.docs.map((d) => OfferModel.fromFirestore(d)).toList();
  }

  // ─── Fetch Active Products ───────────────────────────────────────────────────
  Future<List<ProductModel>> _fetchActiveProducts() async {
    final snap = await _firestore
        .collection(AppConstants.productsCollection)
        .where('is_active', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .limit(AppConstants.productsPerPage * 3) // Cache 3 pages
        .get();

    return snap.docs.map((d) => ProductModel.fromFirestore(d)).toList();
  }

  // ─── Real-time Listeners ─────────────────────────────────────────────────────
  /// Attaches Firestore real-time listeners so any remote change immediately
  /// propagates to the UI without manual refresh.
  void _startRealTimeListeners() {
    // Offers listener
    _offersListener = _firestore
        .collection(AppConstants.offersCollection)
        .where('is_active', isEqualTo: true)
        .snapshots()
        .listen((snap) {
          final offers = snap.docs
              .map((d) => OfferModel.fromFirestore(d))
              .where((o) => !o.isExpired) // Client-side expiry check
              .toList();
          _offersController.add(offers);
          _cacheOffers(offers); // Keep cache warm
        });

    // Products listener
    _productsListener = _firestore
        .collection(AppConstants.productsCollection)
        .where('is_active', isEqualTo: true)
        .limit(100)
        .snapshots()
        .listen((snap) {
          final products = snap.docs
              .map((d) => ProductModel.fromFirestore(d))
              .toList();
          _productsController.add(products);
          _cacheProducts(products);
        });
  }

  // ─── Periodic Sync ───────────────────────────────────────────────────────────
  void _schedulePeriodicSync() {
    // Full refresh every N minutes (catches edge cases real-time listeners miss)
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: AppConstants.cacheDurationMinutes),
      (_) => refreshData(),
    );
  }

  // ─── Cache Helpers ───────────────────────────────────────────────────────────
  Future<void> _cacheOffers(List<OfferModel> offers) async {
    final json = jsonEncode(offers.map((o) => o.toMap()).toList());
    await _prefs.setString(AppConstants.cacheKeyOffers, json);
  }

  Future<void> _cacheProducts(List<ProductModel> products) async {
    final json = jsonEncode(products.map((p) => p.toMap()).toList());
    await _prefs.setString(AppConstants.cacheKeyProducts, json);
  }

  void _emitCachedData() {
    final cachedOffers = _prefs.getString(AppConstants.cacheKeyOffers);
    if (cachedOffers != null) {
      final list = (jsonDecode(cachedOffers) as List)
          .map((e) => OfferModel.fromMap(e))
          .toList();
      _offersController.add(list);
    }

    final cachedProducts = _prefs.getString(AppConstants.cacheKeyProducts);
    if (cachedProducts != null) {
      final list = (jsonDecode(cachedProducts) as List)
          .map((e) => ProductModel.fromMap(e))
          .toList();
      _productsController.add(list);
    }
  }

  // ─── Cache Read Helpers (for providers on cold start) ────────────────────────
  List<OfferModel> getCachedOffers() {
    final json = _prefs.getString(AppConstants.cacheKeyOffers);
    if (json == null) return [];
    return (jsonDecode(json) as List)
        .map((e) => OfferModel.fromMap(e))
        .toList();
  }

  List<ProductModel> getCachedProducts() {
    final json = _prefs.getString(AppConstants.cacheKeyProducts);
    if (json == null) return [];
    return (jsonDecode(json) as List)
        .map((e) => ProductModel.fromMap(e))
        .toList();
  }

  bool get isCacheStale {
    final ts = _prefs.getInt(AppConstants.cacheKeyLastSync);
    if (ts == null) return true;
    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(ts),
    );
    return age.inMinutes > AppConstants.cacheDurationMinutes;
  }

  // ─── Dispose ────────────────────────────────────────────────────────────────
  void dispose() {
    _offersListener?.cancel();
    _productsListener?.cancel();
    _periodicSyncTimer?.cancel();
    _offersController.close();
    _productsController.close();
    _syncStatusController.close();
  }
}

enum SyncStatus { idle, syncing, synced, error }
