// lib/presentation/providers/offers_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/remote/sync_service.dart';
import '../../data/models/offer_model.dart';
import '../../domain/entities/offer_entity.dart';
import '../../core/constants/app_constants.dart';

class OffersProvider extends ChangeNotifier {
  final SyncService      _syncService;
  final FirebaseFirestore _firestore;

  List<OfferModel> _offers = [];
  bool             _isLoading = false;
  String?          _error;
  StreamSubscription? _sub;

  OffersProvider({
    required SyncService syncService,
    required FirebaseFirestore firestore,
  })  : _syncService = syncService,
        _firestore   = firestore {
    _listenToSync();
    _loadCached();
  }

  // ─── Getters ─────────────────────────────────────────────────────────────────
  List<OfferModel> get offers       => _offers;
  List<OfferModel> get activeOffers => _offers.where((o) => o.isLive).toList();
  bool             get isLoading    => _isLoading;
  String?          get error        => _error;

  void _listenToSync() {
    _sub = _syncService.offersStream.listen((offers) {
      _offers = offers;
      notifyListeners();
    });
  }

  void _loadCached() {
    _offers = _syncService.getCachedOffers();
    notifyListeners();
  }

  // ─── CRUD for Admin ──────────────────────────────────────────────────────────

  Future<void> createOffer(OfferModel offer) async {
    _isLoading = true; notifyListeners();
    try {
      await _firestore
          .collection(AppConstants.offersCollection)
          .doc(offer.id)
          .set(offer.toFirestore());
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<void> updateOffer(OfferModel offer) async {
    await _firestore
        .collection(AppConstants.offersCollection)
        .doc(offer.id)
        .update(offer.toFirestore());
  }

  Future<void> deactivateOffer(String offerId) async {
    await _firestore
        .collection(AppConstants.offersCollection)
        .doc(offerId)
        .update({'is_active': false});
  }

  Future<void> deleteOffer(String offerId) async {
    await _firestore
        .collection(AppConstants.offersCollection)
        .doc(offerId)
        .delete();
  }

  Future<void> refresh() => _syncService.refreshData();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
