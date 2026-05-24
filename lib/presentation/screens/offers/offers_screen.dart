// lib/presentation/screens/offers/offers_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/offers_provider.dart';
import '../../../domain/entities/offer_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(title: const Text('Deals & Offers')),
      body: Consumer<OffersProvider>(
        builder: (_, offersProvider, __) {
          final offers = offersProvider.activeOffers;

          if (offersProvider.isLoading && offers.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            );
          }

          if (offers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_offer_outlined,
                      color: AppTheme.textMuted, size: 52),
                  const SizedBox(height: 16),
                  const Text('No active offers right now',
                      style: AppTheme.headlineMedium),
                  const SizedBox(height: 8),
                  const Text('Check back later for amazing deals!',
                      style: AppTheme.bodyMedium),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => offersProvider.refresh(),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: offersProvider.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              itemCount: offers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _OfferCard(offer: offers[i]),
            ),
          );
        },
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final OfferEntity offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    // Map offer type to accent colour
    final Color tint = offer.offerType == OfferType.freeShipping
        ? AppTheme.info
        : offer.offerType == OfferType.buyOneGetOne
            ? AppTheme.success
            : AppTheme.accent;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint.withOpacity(0.18), AppTheme.card],
        ),
        border: Border.all(color: tint.withOpacity(0.35)),
      ),
      child: Stack(
        children: [
          // Background decorative circle
          Positioned(
            right: -30, top: -30,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tint.withOpacity(0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: tint.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: tint.withOpacity(0.4)),
                      ),
                      child: Text(
                        _discountLabel(),
                        style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900,
                          color: tint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(offer.title,
                            style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            )),
                          const SizedBox(height: 2),
                          Text(offer.description,
                            style: AppTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Coupon code
                if (offer.couponCode != null) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: tint.withOpacity(0.6),
                            style: BorderStyle.solid,
                          ),
                          color: tint.withOpacity(0.05),
                        ),
                        child: Text(
                          offer.couponCode!,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: tint, letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          // Copy to clipboard
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${offer.couponCode} copied to clipboard'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: tint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Copy',
                            style: TextStyle(
                              color: Colors.white, fontSize: 12,
                              fontWeight: FontWeight.w700,
                            )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // Footer row
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 13, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(offer.expiryLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: offer.daysRemaining <= 2
                            ? AppTheme.error
                            : AppTheme.textMuted,
                        fontWeight: offer.daysRemaining <= 2
                            ? FontWeight.w600 : FontWeight.w400,
                      )),
                    const Spacer(),
                    if (offer.minOrderAmount != null)
                      Text(
                        'Min order \$${offer.minOrderAmount!.toStringAsFixed(0)}',
                        style: AppTheme.bodySmall,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _discountLabel() {
    switch (offer.offerType) {
      case OfferType.freeShipping: return 'FREE\nSHIPPING';
      case OfferType.buyOneGetOne: return 'BOGO';
      case OfferType.fixedAmount:  return '-\$${offer.discount.toInt()}';
      case OfferType.percentage:
      default:                     return '${offer.discount.toInt()}%\nOFF';
    }
  }
}
