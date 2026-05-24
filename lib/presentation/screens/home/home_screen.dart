// lib/presentation/screens/home/home_screen.dart
// Main customer home: banner carousel, offers strip, high-density product grid

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/offers_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  int _bannerIndex = 0;

  final List<Map<String, dynamic>> _banners = [
    {'title': 'Summer Sale', 'subtitle': 'Up to 60% off', 'color': 0xFFD1848C},
    {'title': 'New Arrivals', 'subtitle': 'Fresh collections', 'color': 0xFF4CAF82},
    {'title': 'Flash Deals', 'subtitle': 'Limited time only', 'color': 0xFF64B5F6},
  ];

  final List<Map<String, String>> _categories = [
    {'id': 'fashion',     'name': 'Fashion',     'emoji': '👗'},
    {'id': 'electronics', 'name': 'Electronics', 'emoji': '📱'},
    {'id': 'home',        'name': 'Home',         'emoji': '🏠'},
    {'id': 'beauty',      'name': 'Beauty',       'emoji': '💄'},
    {'id': 'sports',      'name': 'Sports',       'emoji': '⚽'},
    {'id': 'kids',        'name': 'Kids',         'emoji': '🧸'},
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: RefreshIndicator(
        color: AppTheme.accent,
        backgroundColor: AppTheme.card,
        onRefresh: () => context.read<ProductsProvider>().refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildBannerCarousel()),
            SliverToBoxAdapter(child: _buildOffersStrip()),
            SliverToBoxAdapter(child: _buildCategoryRow()),
            SliverToBoxAdapter(child: _buildSectionHeader('Featured')),
            _buildFeaturedGrid(),
            SliverToBoxAdapter(child: _buildSectionHeader('All Products')),
            _buildProductsGrid(),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      backgroundColor: AppTheme.primary,
      title: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [AppTheme.accent, Color(0xFFE8A0A8)],
              ),
            ),
            child: const Center(
              child: Text('D', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white,
              )),
            ),
          ),
          const SizedBox(width: 10),
          const Text('DAVA STORE',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
              letterSpacing: 3, color: AppTheme.textPrimary),
          ),
        ],
      ),
      actions: [
        // Notification bell
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary),
          onPressed: () {},
        ),
        // Cart with badge
        Consumer<CartProvider>(
          builder: (_, cart, __) => Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.textPrimary),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(
                      color: AppTheme.accent, shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SearchBarWidget(
        onSearch: (q) => context.read<ProductsProvider>().search(q),
        onCameraPressed: () => _openVisualSearch(),
      ),
    );
  }

  void _openVisualSearch() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Visual Search', style: AppTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Take a photo or upload an image\nto find similar products',
              style: AppTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _visualSearchOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _visualSearchOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _visualSearchOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.accent, size: 28),
            const SizedBox(height: 8),
            Text(label, style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  // ─── Banner Carousel ─────────────────────────────────────────────────────────
  Widget _buildBannerCarousel() {
    return Column(
      children: [
        const SizedBox(height: 16),
        CarouselSlider(
          options: CarouselOptions(
            height: 160,
            viewportFraction: 0.88,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (i, _) => setState(() => _bannerIndex = i),
          ),
          items: _banners.map((b) => _bannerCard(b)).toList(),
        ),
        const SizedBox(height: 10),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) => AnimatedContainer(
            duration: AppConstants.animFast,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _bannerIndex ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == _bannerIndex ? AppTheme.accent : AppTheme.divider,
              borderRadius: BorderRadius.circular(3),
            ),
          )),
        ),
      ],
    );
  }

  Widget _bannerCard(Map<String, dynamic> b) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(b['color'] as int),
            Color(b['color'] as int).withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20, bottom: -20,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(b['title'] as String,
                  style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w900,
                    color: Colors.white,
                  )),
                const SizedBox(height: 4),
                Text(b['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 14, color: Colors.white.withOpacity(0.85),
                  )),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Shop Now',
                    style: TextStyle(
                      color: Color(b['color'] as int),
                      fontWeight: FontWeight.w700, fontSize: 12,
                    )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Offers Strip ─────────────────────────────────────────────────────────────
  Widget _buildOffersStrip() {
    return Consumer<OffersProvider>(
      builder: (_, offersProvider, __) {
        final offers = offersProvider.activeOffers;
        if (offers.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Hot Deals', style: AppTheme.headlineMedium),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See all'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: offers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _offerChip(offers[i]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _offerChip(offer) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(0.3),
            AppTheme.secondary,
          ],
        ),
        border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${offer.discount.toInt()}% OFF',
            style: const TextStyle(
              color: AppTheme.accent, fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(offer.title,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(offer.expiryLabel,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ─── Category Row ─────────────────────────────────────────────────────────────
  Widget _buildCategoryRow() {
    return Consumer<ProductsProvider>(
      builder: (_, products, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Categories', style: AppTheme.headlineMedium),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = products.selectedCategory == cat['id'];
                return GestureDetector(
                  onTap: () => products.filterByCategory(
                    selected ? null : cat['id'],
                  ),
                  child: AnimatedContainer(
                    duration: AppConstants.animFast,
                    width: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      color: selected
                          ? AppTheme.accent.withOpacity(0.2)
                          : AppTheme.glassWhite,
                      border: Border.all(
                        color: selected ? AppTheme.accent : AppTheme.glassBorder,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat['emoji']!, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(cat['name']!,
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600,
                            color: selected ? AppTheme.accent : AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.headlineMedium),
          Consumer<ProductsProvider>(
            builder: (_, p, __) => PopupMenuButton<String>(
              color: AppTheme.surface,
              icon: const Icon(Icons.sort_rounded,
                color: AppTheme.textSecondary, size: 20),
              onSelected: (v) => p.setSortBy(v),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'newest',
                  child: Text('Newest', style: TextStyle(color: AppTheme.textPrimary))),
                PopupMenuItem(value: 'price_asc',
                  child: Text('Price: Low to High', style: TextStyle(color: AppTheme.textPrimary))),
                PopupMenuItem(value: 'price_desc',
                  child: Text('Price: High to Low', style: TextStyle(color: AppTheme.textPrimary))),
                PopupMenuItem(value: 'rating',
                  child: Text('Top Rated', style: TextStyle(color: AppTheme.textPrimary))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Featured Grid ────────────────────────────────────────────────────────────
  Widget _buildFeaturedGrid() {
    return Consumer<ProductsProvider>(
      builder: (_, products, __) {
        final featured = products.featuredProducts;
        if (featured.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: featured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => SizedBox(
                width: 150,
                child: ProductCard(product: featured[i], compact: true),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Main Product Grid ────────────────────────────────────────────────────────
  Widget _buildProductsGrid() {
    return Consumer<ProductsProvider>(
      builder: (_, products, __) {
        if (products.isLoading && products.products.isEmpty) {
          return SliverToBoxAdapter(child: _buildShimmerGrid());
        }
        if (products.products.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: Text('No products found', style: AppTheme.bodyMedium),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:    AppConstants.gridCrossAxisCount,
              mainAxisSpacing:   AppConstants.gridSpacing,
              crossAxisSpacing:  AppConstants.gridSpacing,
              childAspectRatio:  AppConstants.gridChildAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => ProductCard(product: products.products[i]),
              childCount: products.products.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 12,
        crossAxisSpacing: 12, childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
      ),
    );
  }
}
