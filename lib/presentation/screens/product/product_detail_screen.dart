// lib/presentation/screens/product/product_detail_screen.dart
// Full product page: image gallery, rating, add-to-cart, offer badge

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/cart_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductEntity product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImage = 0;
  int _quantity = 1;
  String? _selectedSize;
  String? _selectedColor;

  final List<String> _sizes   = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<Color>  _colors  = [
    const Color(0xFFD1848C), const Color(0xFF182421),
    const Color(0xFF18242C), const Color(0xFFFFFFFF),
    const Color(0xFFFFB74D),
  ];

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: AppTheme.primary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.glassDark,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary, size: 16),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.glassDark,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: IconButton(
              icon: const Icon(Icons.share_outlined,
                  color: AppTheme.textPrimary, size: 18),
              onPressed: () {},
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Image gallery ──
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildImageGallery(p)),
                SliverToBoxAdapter(child: _buildDetails(p)),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(p),
    );
  }

  // ─── Image Gallery ────────────────────────────────────────────────────────────
  Widget _buildImageGallery(ProductEntity p) {
    final images = p.imageUrls.isEmpty
        ? <String>['']
        : p.imageUrls;

    return SizedBox(
      height: 380,
      child: Stack(
        children: [
          // Main image
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _selectedImage = i),
            itemBuilder: (_, i) => images[i].isEmpty
                ? Container(
                    color: AppTheme.surface,
                    child: const Center(
                      child: Icon(Icons.image_outlined,
                          color: AppTheme.textMuted, size: 60),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: images[i],
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppTheme.surface),
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.surface,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: AppTheme.textMuted, size: 48),
                    ),
                  ),
          ),

          // Gradient overlay at bottom
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppTheme.primary.withOpacity(0.9)],
                ),
              ),
            ),
          ),

          // Sale badge
          if (p.isOnSale)
            Positioned(
              top: 96, left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '-${p.discountPercentage.toInt()}% OFF',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 12,
                    fontWeight: FontWeight.w800, letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

          // Dot indicators
          if (images.length > 1)
            Positioned(
              bottom: 12, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) => AnimatedContainer(
                  duration: AppConstants.animFast,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _selectedImage ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _selectedImage
                        ? AppTheme.accent : AppTheme.glassBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Product Details ──────────────────────────────────────────────────────────
  Widget _buildDetails(ProductEntity p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.glassWhite,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Text(p.categoryName,
              style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 11, letterSpacing: 1,
              )),
          ),
          const SizedBox(height: 10),

          // Title
          Text(p.title,
            style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary, height: 1.2,
            )),
          const SizedBox(height: 10),

          // Rating & reviews
          Row(
            children: [
              ...List.generate(5, (i) => Icon(
                i < p.rating.floor()
                    ? Icons.star_rounded
                    : (i < p.rating
                        ? Icons.star_half_rounded
                        : Icons.star_outline_rounded),
                color: const Color(0xFFFFB74D), size: 16,
              )),
              const SizedBox(width: 8),
              Text('${p.rating}  (${p.reviewCount} reviews)',
                style: AppTheme.bodySmall),
              const Spacer(),
              if (p.brand != null)
                Text('by ${p.brand}',
                  style: const TextStyle(
                    color: AppTheme.accent, fontSize: 12,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          const SizedBox(height: 16),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${p.effectivePrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900,
                  color: AppTheme.accent,
                ),
              ),
              if (p.isOnSale) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('\$${p.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16, color: AppTheme.textMuted,
                      decoration: TextDecoration.lineThrough,
                    )),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Save \$${(p.price - p.effectivePrice).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppTheme.success, fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Sizes
          if (p.attributes.containsKey('sizes') || true) ...[
            const Text('Select Size',
              style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 13,
                fontWeight: FontWeight.w600, letterSpacing: 0.5,
              )),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _sizes.map((s) {
                final selected = _selectedSize == s;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSize = s),
                  child: AnimatedContainer(
                    duration: AppConstants.animFast,
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: selected
                          ? AppTheme.accent.withOpacity(0.15)
                          : AppTheme.glassWhite,
                      border: Border.all(
                        color: selected ? AppTheme.accent : AppTheme.glassBorder,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(s,
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: selected ? AppTheme.accent : AppTheme.textSecondary,
                        )),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Colors
          const Text('Select Color',
            style: TextStyle(
              color: AppTheme.textSecondary, fontSize: 13,
              fontWeight: FontWeight.w600, letterSpacing: 0.5,
            )),
          const SizedBox(height: 10),
          Row(
            children: _colors.asMap().entries.map((e) {
              final selected = _selectedColor == e.key.toString();
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = e.key.toString()),
                child: AnimatedContainer(
                  duration: AppConstants.animFast,
                  margin: const EdgeInsets.only(right: 8),
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: e.value,
                    border: Border.all(
                      color: selected ? AppTheme.accent : AppTheme.glassBorder,
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: selected ? [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.4),
                        blurRadius: 6, spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Quantity selector
          Row(
            children: [
              const Text('Quantity',
                style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
              const Spacer(),
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    _qtyBtn(Icons.remove, () {
                      if (_quantity > 1) setState(() => _quantity--);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text('$_quantity',
                        style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        )),
                    ),
                    _qtyBtn(Icons.add, () => setState(() => _quantity++)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          const Text('Description',
            style: TextStyle(
              color: AppTheme.textSecondary, fontSize: 13,
              fontWeight: FontWeight.w600, letterSpacing: 0.5,
            )),
          const SizedBox(height: 8),
          Text(p.description,
            style: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 14, height: 1.6,
            )),

          // Tags
          if (p.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: p.tags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.glassWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Text('#$t',
                  style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 11,
                  )),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.glassWhite,
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Icon(icon, size: 14, color: AppTheme.textPrimary),
      ),
    );
  }

  // ─── Bottom Bar ───────────────────────────────────────────────────────────────
  Widget _buildBottomBar(ProductEntity p) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final inCart = cart.isInCart(p.id);
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            border: const Border(top: BorderSide(color: AppTheme.divider)),
          ),
          child: Row(
            children: [
              // Wishlist
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.glassWhite,
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: const Icon(Icons.favorite_border_rounded,
                    color: AppTheme.accent),
              ),
              const SizedBox(width: 12),
              // Add to cart
              Expanded(
                child: AnimatedContainer(
                  duration: AppConstants.animFast,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: inCart ? AppTheme.success : AppTheme.accent,
                  ),
                  child: TextButton(
                    onPressed: p.inStock ? () {
                      for (var i = 0; i < _quantity; i++) {
                        cart.addToCart(p);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '$_quantity × ${p.title} added to cart'),
                          backgroundColor: AppTheme.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } : null,
                    child: Text(
                      !p.inStock
                          ? 'Out of Stock'
                          : inCart
                              ? '✓ Added to Cart'
                              : 'Add to Cart',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Buy now
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD1848C), Color(0xFFE8A0A8)],
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.flash_on_rounded,
                      color: Colors.white, size: 22),
                  onPressed: p.inStock ? () {
                    cart.addToCart(p);
                    Navigator.pushNamed(context, '/cart');
                  } : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
