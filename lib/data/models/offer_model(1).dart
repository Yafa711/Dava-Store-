// lib/data/models/offer_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/offer_entity.dart';

class OfferModel extends OfferEntity {
  const OfferModel({
    required super.id,
    required super.title,
    required super.description,
    required super.discount,
    super.couponCode,
    required super.expiryDate,
    required super.isActive,
    super.imageUrl,
    super.categoryId,
    super.applicableProductIds,
    super.offerType,
    super.minOrderAmount,
    required super.createdAt,
    required super.createdBy,
  });

  factory OfferModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OfferModel(
      id:           doc.id,
      title:        d['title'] ?? '',
      description:  d['description'] ?? '',
      discount:     (d['discount'] ?? 0).toDouble(),
      couponCode:   d['coupon_code'],
      expiryDate:   (d['expiry_date'] as Timestamp).toDate(),
      isActive:     d['is_active'] ?? true,
      imageUrl:     d['image_url'],
      categoryId:   d['category_id'],
      applicableProductIds: List<String>.from(d['applicable_product_ids'] ?? []),
      offerType:    OfferType.values.firstWhere(
        (e) => e.name == (d['offer_type'] ?? 'percentage'),
        orElse: () => OfferType.percentage,
      ),
      minOrderAmount: d['min_order_amount']?.toDouble(),
      createdAt:    (d['created_at'] as Timestamp).toDate(),
      createdBy:    d['created_by'] ?? '',
    );
  }

  factory OfferModel.fromMap(Map<String, dynamic> d) {
    return OfferModel(
      id:           d['id'] ?? '',
      title:        d['title'] ?? '',
      description:  d['description'] ?? '',
      discount:     (d['discount'] ?? 0).toDouble(),
      couponCode:   d['coupon_code'],
      expiryDate:   DateTime.fromMillisecondsSinceEpoch(d['expiry_date'] ?? 0),
      isActive:     d['is_active'] ?? true,
      imageUrl:     d['image_url'],
      categoryId:   d['category_id'],
      applicableProductIds: List<String>.from(d['applicable_product_ids'] ?? []),
      offerType:    OfferType.values.firstWhere(
        (e) => e.name == (d['offer_type'] ?? 'percentage'),
        orElse: () => OfferType.percentage,
      ),
      minOrderAmount: d['min_order_amount']?.toDouble(),
      createdAt:    DateTime.fromMillisecondsSinceEpoch(d['created_at'] ?? 0),
      createdBy:    d['created_by'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title':                 title,
      'description':           description,
      'discount':              discount,
      'coupon_code':           couponCode,
      'expiry_date':           Timestamp.fromDate(expiryDate),
      'is_active':             isActive,
      'image_url':             imageUrl,
      'category_id':           categoryId,
      'applicable_product_ids': applicableProductIds,
      'offer_type':            offerType.name,
      'min_order_amount':      minOrderAmount,
      'created_at':            Timestamp.fromDate(createdAt),
      'created_by':            createdBy,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id':                    id,
      'title':                 title,
      'description':           description,
      'discount':              discount,
      'coupon_code':           couponCode,
      'expiry_date':           expiryDate.millisecondsSinceEpoch,
      'is_active':             isActive,
      'image_url':             imageUrl,
      'category_id':           categoryId,
      'applicable_product_ids': applicableProductIds,
      'offer_type':            offerType.name,
      'min_order_amount':      minOrderAmount,
      'created_at':            createdAt.millisecondsSinceEpoch,
      'created_by':            createdBy,
    };
  }
}
