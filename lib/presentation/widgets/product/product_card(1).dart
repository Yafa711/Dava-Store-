// lib/presentation/widgets/product/product_card.dart
// High-density product card with glassmorphism & sale badge

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/cart_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final bool compact;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pushNamed(
        context, '/product', arguments: product,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          color: AppTheme.card,
          border: Border.all(color: AppTheme.glassBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: compact ? 4 : 5, child: _buildImage()),
            Expanded(flex: compact ? 3 : 3, child: _buildInfo(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        // Product image
        SizedBox.expand(
          child: product.primaryImage.isEmpty
            ? Container(
                color: AppTheme.surface,
                child: const Icon(Icons.image_outlined,
                  color: AppTheme.textMuted, size: 32),
              )
            : CachedNetworkImage(
                imageUrl: product.primaryImage,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppTheme.surface),
                errorWidget: (_, __, ___) => Container(
                  color: AppTheme.surface,
                  child: const Icon(Icons.image_not_supported_outlined,
                    color: AppTheme.textMuted, size: 28),
                ),
              ),
        ),

        // Sale badge
        if (product.isOnSale)
          Positioned(
            top: 8, left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-${product.discountPercentage.toInt()}%',
                style: const TextStyle(
                  color: Colors.white, fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

        // Out of stock overlay
        if (!product.inStock)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const Center(
                child: Text('Out of Stock',
                  style: TextStyle(
                    color: Colors.white, fontSize: 12,
                    fontWeight: FontWeight.w600,
                  )),
              ),
            ),
          ),

        // Quick add button (bottom right)
        if (product.inStock)
          Positioned(
            bottom: 6, right: 6,
            child: Consumer<CartProvider>(
              builder: (context, cart, _) {
                final inCart = cart.isInCart(product.id);
                return GestureDetector(
                  onTap: () {
                    cart.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.title} added to cart'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: AppConstants.animFast,
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: inCart ? AppTheme.accent : AppTheme.glassWhite,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: inCart ? AppTheme.accent : AppTheme.glassBorder,
                      ),
                    ),
                    child: Icon(
                      inCart ? Icons.check : Icons.add,
                      color: Colors.white, size: 14,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            product.title,
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary, height: 1.3,
            ),
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Rating
          if (!compact) Row(
            children: [
              const Icon(Icons.star_rounded,
                color: Color(0xFFFFB74D), size: 12),
              const SizedBox(width: 2),
              Text(
                product.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 10, color: AppTheme.textMuted,
                ),
              ),
              Text(
                ' (${product.reviewCount})',
                style: const TextStyle(
                  fontSize: 10, color: AppTheme.textMuted,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Price row
          Row(
            children: [
              Text(
                '\$${product.effectivePrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800,
                  color: AppTheme.accent,
                ),
              ),
              if (product.isOnSale) ...[
                const SizedBox(width: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 10, color: AppTheme.textMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
