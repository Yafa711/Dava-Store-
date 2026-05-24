// lib/presentation/providers/products_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/remote/sync_service.dart';
import '../../data/models/product_model.dart';

enum LoadStatus { initial, loading, loaded, error }

class ProductsProvider extends ChangeNotifier {
  final SyncService _syncService;

  List<ProductModel> _products       = [];
  List<ProductModel> _filteredProducts = [];
  LoadStatus         _status         = LoadStatus.initial;
  String?            _error;
  String             _searchQuery    = '';
  String?            _selectedCategory;
  String             _sortBy         = 'newest';
  StreamSubscription? _sub;

  ProductsProvider({required SyncService syncService})
      : _syncService = syncService {
    _listenToSync();
    _loadCached();
  }

  // ─── Getters ──────────────────────────────────────────────────────────────────
  List<ProductModel> get products         => _filteredProducts;
  List<ProductModel> get featuredProducts =>
      _products.where((p) => p.isFeatured).take(10).toList();
  List<ProductModel> get saleProducts     =>
      _products.where((p) => p.isOnSale).toList();
  LoadStatus         get status           => _status;
  String?            get error            => _error;
  String             get searchQuery      => _searchQuery;
  String?            get selectedCategory => _selectedCategory;
  bool               get isLoading        => _status == LoadStatus.loading;

  // ─── Visual Search ────────────────────────────────────────────────────────────
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCategory(String? categoryId) {
    _selectedCategory = categoryId;
    _applyFilters();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    _applyFilters();
  }

  void _applyFilters() {
    var list = List<ProductModel>.from(_products);

    // Text search across title, description, brand, tags
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) =>
        p.title.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q) ||
        (p.brand?.toLowerCase().contains(q) ?? false) ||
        p.tags.any((t) => t.toLowerCase().contains(q)) ||
        p.categoryName.toLowerCase().contains(q)
      ).toList();
    }

    // Category filter
    if (_selectedCategory != null) {
      list = list.where((p) => p.categoryId == _selectedCategory).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case 'price_desc':
        list.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'newest':
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    _filteredProducts = list;
    notifyListeners();
  }

  void _listenToSync() {
    _sub = _syncService.productsStream.listen((products) {
      _products         = products;
      _status           = LoadStatus.loaded;
      _applyFilters();
    });
  }

  void _loadCached() {
    _products         = _syncService.getCachedProducts();
    _filteredProducts = _products;
    if (_products.isNotEmpty) _status = LoadStatus.loaded;
    notifyListeners();
  }

  Future<void> refresh() => _syncService.refreshData();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
