// lib/presentation/providers/cart_provider.dart

import 'package:flutter/foundation.dart';
import '../../domain/entities/product_entity.dart';

class CartItem {
  final ProductEntity product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.effectivePrice * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  String? _appliedCoupon;
  double  _couponDiscount = 0;

  Map<String, CartItem> get items     => _items;
  int                   get itemCount => _items.values.fold(0, (s, i) => s + i.quantity);
  String?               get appliedCoupon => _appliedCoupon;

  double get subtotal =>
      _items.values.fold(0, (s, i) => s + i.total);

  double get discountAmount => subtotal * (_couponDiscount / 100);
  double get total          => subtotal - discountAmount;

  void addToCart(ProductEntity product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
    } else {
      _items[productId]?.quantity = quantity;
      notifyListeners();
    }
  }

  void applyCoupon(String code, double discountPercent) {
    _appliedCoupon  = code;
    _couponDiscount = discountPercent;
    notifyListeners();
  }

  void removeCoupon() {
    _appliedCoupon  = null;
    _couponDiscount = 0;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedCoupon  = null;
    _couponDiscount = 0;
    notifyListeners();
  }

  bool isInCart(String productId) => _items.containsKey(productId);
}
