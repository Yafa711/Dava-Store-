// lib/data/models/product_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    super.salePrice,
    required super.categoryId,
    required super.categoryName,
    required super.imageUrls,
    super.rating,
    super.reviewCount,
    required super.stockQuantity,
    super.isActive,
    super.isFeatured,
    super.attributes,
    required super.createdAt,
    super.brand,
    super.tags,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id:            doc.id,
      title:         d['title'] ?? '',
      description:   d['description'] ?? '',
      price:         (d['price'] ?? 0).toDouble(),
      salePrice:     d['sale_price']?.toDouble(),
      categoryId:    d['category_id'] ?? '',
      categoryName:  d['category_name'] ?? '',
      imageUrls:     List<String>.from(d['image_urls'] ?? []),
      rating:        (d['rating'] ?? 0).toDouble(),
      reviewCount:   d['review_count'] ?? 0,
      stockQuantity: d['stock_quantity'] ?? 0,
      isActive:      d['is_active'] ?? true,
      isFeatured:    d['is_featured'] ?? false,
      attributes:    Map<String, dynamic>.from(d['attributes'] ?? {}),
      createdAt:     (d['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      brand:         d['brand'],
      tags:          List<String>.from(d['tags'] ?? []),
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> d) {
    return ProductModel(
      id:            d['id'] ?? '',
      title:         d['title'] ?? '',
      description:   d['description'] ?? '',
      price:         (d['price'] ?? 0).toDouble(),
      salePrice:     d['sale_price']?.toDouble(),
      categoryId:    d['category_id'] ?? '',
      categoryName:  d['category_name'] ?? '',
      imageUrls:     List<String>.from(d['image_urls'] ?? []),
      rating:        (d['rating'] ?? 0).toDouble(),
      reviewCount:   d['review_count'] ?? 0,
      stockQuantity: d['stock_quantity'] ?? 0,
      isActive:      d['is_active'] ?? true,
      isFeatured:    d['is_featured'] ?? false,
      attributes:    Map<String, dynamic>.from(d['attributes'] ?? {}),
      createdAt:     DateTime.fromMillisecondsSinceEpoch(d['created_at'] ?? 0),
      brand:         d['brand'],
      tags:          List<String>.from(d['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title, 'description': description, 'price': price,
    'sale_price': salePrice, 'category_id': categoryId,
    'category_name': categoryName, 'image_urls': imageUrls,
    'rating': rating, 'review_count': reviewCount,
    'stock_quantity': stockQuantity, 'is_active': isActive,
    'is_featured': isFeatured, 'attributes': attributes,
    'created_at': Timestamp.fromDate(createdAt),
    'brand': brand, 'tags': tags,
  };

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'description': description, 'price': price,
    'sale_price': salePrice, 'category_id': categoryId,
    'category_name': categoryName, 'image_urls': imageUrls,
    'rating': rating, 'review_count': reviewCount,
    'stock_quantity': stockQuantity, 'is_active': isActive,
    'is_featured': isFeatured, 'attributes': attributes,
    'created_at': createdAt.millisecondsSinceEpoch,
    'brand': brand, 'tags': tags,
  };
}
