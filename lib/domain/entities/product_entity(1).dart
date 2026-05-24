// lib/domain/entities/product_entity.dart

import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? salePrice;
  final String categoryId;
  final String categoryName;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final int stockQuantity;
  final bool isActive;
  final bool isFeatured;
  final Map<String, dynamic> attributes; // size, color, etc.
  final DateTime createdAt;
  final String? brand;
  final List<String> tags;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.salePrice,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrls,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.stockQuantity,
    this.isActive = true,
    this.isFeatured = false,
    this.attributes = const {},
    required this.createdAt,
    this.brand,
    this.tags = const [],
  });

  bool get isOnSale => salePrice != null && salePrice! < price;
  bool get inStock  => stockQuantity > 0;

  double get effectivePrice => salePrice ?? price;

  double get discountPercentage {
    if (!isOnSale) return 0;
    return ((price - salePrice!) / price * 100).roundToDouble();
  }

  String get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : '';

  @override
  List<Object?> get props => [id, title, price, salePrice, stockQuantity];
}
