// lib/presentation/screens/admin/manage_offers_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/offers_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/offer_model.dart';
import '../../../domain/entities/offer_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class ManageOffersScreen extends StatelessWidget {
  const ManageOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(title: const Text('Manage Offers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOfferSheet(context),
        backgroundColor: AppTheme.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Offer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Consumer<OffersProvider>(
        builder: (_, offersProvider, __) {
          final offers = offersProvider.offers;
          if (offers.isEmpty) {
            return const Center(
              child: Text('No offers yet. Tap + to create one.',
                style: AppTheme.bodyMedium),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: offers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _offerCard(context, offers[i]),
          );
        },
      ),
    );
  }

  Widget _offerCard(BuildContext context, OfferModel offer) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: offer.isLive ? AppTheme.success.withOpacity(0.4) : AppTheme.glassBorder,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Discount badge
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: offer.isLive
                  ? AppTheme.accent.withOpacity(0.15)
                  : AppTheme.glassWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${offer.discount.toInt()}%',
                style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w900,
                  color: offer.isLive ? AppTheme.accent : AppTheme.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.title, style: AppTheme.titleMedium),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      offer.isLive ? Icons.circle : Icons.circle_outlined,
                      size: 8,
                      color: offer.isLive ? AppTheme.success : AppTheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      offer.isLive ? 'Active' : (offer.isExpired ? 'Expired' : 'Inactive'),
                      style: TextStyle(
                        fontSize: 11,
                        color: offer.isLive ? AppTheme.success : AppTheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('• ${offer.expiryLabel}',
                      style: AppTheme.bodySmall),
                  ],
                ),
                if (offer.couponCode != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.divider),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      offer.couponCode!,
                      style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 11,
                        color: AppTheme.textSecondary, letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: AppTheme.surface,
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textMuted),
            onSelected: (action) async {
              final prov = context.read<OffersProvider>();
              if (action == 'deactivate') await prov.deactivateOffer(offer.id);
              if (action == 'delete') await prov.deleteOffer(offer.id);
            },
            itemBuilder: (_) => [
              if (offer.isLive)
                const PopupMenuItem(value: 'deactivate',
                  child: Text('Deactivate', style: TextStyle(color: AppTheme.warning))),
              const PopupMenuItem(value: 'delete',
                child: Text('Delete', style: TextStyle(color: AppTheme.error))),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateOfferSheet(BuildContext context) {
    final titleCtrl    = TextEditingController();
    final descCtrl     = TextEditingController();
    final discountCtrl = TextEditingController();
    final couponCtrl   = TextEditingController();
    DateTime expiryDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Create New Offer', style: AppTheme.headlineMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Offer Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: discountCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Discount %',
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: couponCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Coupon Code (optional)',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: expiryDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(primary: AppTheme.accent),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setState(() => expiryDate = picked);
                  },
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                          color: AppTheme.accent, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'Expires: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.isEmpty || discountCtrl.text.isEmpty) return;
                    final uid = context.read<AuthProvider>().currentUser!.id;
                    final offer = OfferModel(
                      id:          const Uuid().v4(),
                      title:       titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      discount:    double.tryParse(discountCtrl.text) ?? 0,
                      couponCode:  couponCtrl.text.trim().isEmpty
                                     ? null : couponCtrl.text.trim(),
                      expiryDate:  expiryDate,
                      isActive:    true,
                      createdAt:   DateTime.now(),
                      createdBy:   uid,
                    );
                    await context.read<OffersProvider>().createOffer(offer);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Create Offer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
