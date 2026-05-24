// lib/domain/entities/offer_entity.dart
// Offer domain entity with expiry logic

import 'package:equatable/equatable.dart';

class OfferEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double discount;       // Percentage 0–100
  final String? couponCode;
  final DateTime expiryDate;
  final bool isActive;
  final String? imageUrl;
  final String? categoryId;
  final List<String> applicableProductIds; // Empty = all products
  final OfferType offerType;
  final double? minOrderAmount;
  final DateTime createdAt;
  final String createdBy; // Admin uid

  const OfferEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.discount,
    this.couponCode,
    required this.expiryDate,
    required this.isActive,
    this.imageUrl,
    this.categoryId,
    this.applicableProductIds = const [],
    this.offerType = OfferType.percentage,
    this.minOrderAmount,
    required this.createdAt,
    required this.createdBy,
  });

  // ─── Computed Properties ─────────────────────────────────────────────────────

  /// True if offer is still within its validity window
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// An offer is effectively live only if active AND not expired
  bool get isLive => isActive && !isExpired;

  /// Days remaining until expiry (negative if expired)
  int get daysRemaining => expiryDate.difference(DateTime.now()).inDays;

  /// Formatted expiry string
  String get expiryLabel {
    if (isExpired) return 'Expired';
    if (daysRemaining == 0) return 'Expires today';
    if (daysRemaining == 1) return 'Expires tomorrow';
    return 'Expires in $daysRemaining days';
  }

  OfferEntity copyWith({
    String? id, String? title, String? description,
    double? discount, String? couponCode, DateTime? expiryDate,
    bool? isActive, String? imageUrl, String? categoryId,
    List<String>? applicableProductIds, OfferType? offerType,
    double? minOrderAmount, DateTime? createdAt, String? createdBy,
  }) {
    return OfferEntity(
      id:                    id                    ?? this.id,
      title:                 title                 ?? this.title,
      description:           description           ?? this.description,
      discount:              discount              ?? this.discount,
      couponCode:            couponCode            ?? this.couponCode,
      expiryDate:            expiryDate            ?? this.expiryDate,
      isActive:              isActive              ?? this.isActive,
      imageUrl:              imageUrl              ?? this.imageUrl,
      categoryId:            categoryId            ?? this.categoryId,
      applicableProductIds:  applicableProductIds  ?? this.applicableProductIds,
      offerType:             offerType             ?? this.offerType,
      minOrderAmount:        minOrderAmount        ?? this.minOrderAmount,
      createdAt:             createdAt             ?? this.createdAt,
      createdBy:             createdBy             ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [id, title, discount, expiryDate, isActive];
}

enum OfferType {
  percentage, // e.g. 20% off
  fixedAmount, // e.g. $10 off
  freeShipping,
  buyOneGetOne,
}
