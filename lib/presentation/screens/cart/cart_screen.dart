// lib/presentation/screens/cart/cart_screen.dart
// Shopping cart with coupon, order summary, checkout flow

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/cart_provider.dart';
import '../../providers/offers_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _couponController = TextEditingController();
  bool _couponLoading = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: Consumer<CartProvider>(
          builder: (_, cart, __) => Text(
            'Cart  (${cart.itemCount})',
            style: const TextStyle(fontSize: 18, letterSpacing: 1),
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) => cart.itemCount > 0
                ? TextButton(
                    onPressed: () => _confirmClear(context, cart),
                    child: const Text('Clear',
                        style: TextStyle(color: AppTheme.error, fontSize: 13)),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (_, cart, __) {
          if (cart.items.isEmpty) return _buildEmptyCart();
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  children: [
                    ...cart.items.values.map((item) => _cartItem(context, cart, item)),
                    const SizedBox(height: 16),
                    _buildCouponBox(context, cart),
                    const SizedBox(height: 16),
                    _buildOrderSummary(cart),
                  ],
                ),
              ),
              _buildCheckoutBar(context, cart),
            ],
          );
        },
      ),
    );
  }

  // ─── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.glassWhite,
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                color: AppTheme.textMuted, size: 44),
          ),
          const SizedBox(height: 20),
          const Text('Your cart is empty', style: AppTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Start adding products you love!',
              style: AppTheme.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.explore_outlined, size: 18),
            label: const Text('Explore Products'),
          ),
        ],
      ),
    );
  }

  // ─── Cart Item ────────────────────────────────────────────────────────────────
  Widget _cartItem(BuildContext context, CartProvider cart, CartItem item) {
    final p = item.product;
    return Dismissible(
      key: Key(p.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => cart.removeFromCart(p.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppTheme.error, size: 26),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 72, height: 72,
                child: p.primaryImage.isEmpty
                    ? Container(
                        color: AppTheme.surface,
                        child: const Icon(Icons.image_outlined,
                            color: AppTheme.textMuted, size: 28),
                      )
                    : CachedNetworkImage(
                        imageUrl: p.primaryImage,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppTheme.surface),
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.surface,
                          child: const Icon(Icons.image_not_supported_outlined,
                              color: AppTheme.textMuted),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title,
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('\$${p.effectivePrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: AppTheme.accent,
                    )),
                ],
              ),
            ),
            // Qty controls
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _qtyBtn(Icons.remove, () =>
                      cart.updateQuantity(p.id, item.quantity - 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${item.quantity}',
                      style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      )),
                  ),
                  _qtyBtn(Icons.add, () =>
                      cart.updateQuantity(p.id, item.quantity + 1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 26, height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.glassWhite,
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Icon(icon, size: 13, color: AppTheme.textPrimary),
    ),
  );

  // ─── Coupon Box ───────────────────────────────────────────────────────────────
  Widget _buildCouponBox(BuildContext context, CartProvider cart) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Have a coupon?',
            style: TextStyle(
              color: AppTheme.textSecondary, fontSize: 13,
              fontWeight: FontWeight.w600,
            )),
          const SizedBox(height: 10),
          if (cart.appliedCoupon != null)
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.success, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${cart.appliedCoupon} applied!',
                  style: const TextStyle(
                    color: AppTheme.success, fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: cart.removeCoupon,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Remove'),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter coupon code',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _couponLoading
                        ? null
                        : () => _applyCoupon(context, cart),
                    child: _couponLoading
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Apply'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _applyCoupon(BuildContext context, CartProvider cart) async {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() => _couponLoading = true);

    // Look up coupon code in active offers
    final offers = context.read<OffersProvider>().activeOffers;
    final match = offers.where((o) =>
      o.couponCode?.toUpperCase() == code).firstOrNull;

    setState(() => _couponLoading = false);

    if (match != null) {
      cart.applyCoupon(code, match.discount);
      _couponController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${match.discount.toInt()}% discount applied!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid or expired coupon code.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  // ─── Order Summary ────────────────────────────────────────────────────────────
  Widget _buildOrderSummary(CartProvider cart) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            )),
          const SizedBox(height: 12),
          _summaryRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
          if (cart.appliedCoupon != null) ...[
            const SizedBox(height: 6),
            _summaryRow(
              'Discount (${cart.appliedCoupon})',
              '-\$${cart.discountAmount.toStringAsFixed(2)}',
              valueColor: AppTheme.success,
            ),
          ],
          const SizedBox(height: 6),
          _summaryRow('Shipping', 'FREE',
            valueColor: AppTheme.success),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppTheme.divider),
          ),
          _summaryRow(
            'Total',
            '\$${cart.total.toStringAsFixed(2)}',
            isBold: true,
            valueColor: AppTheme.accent,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: TextStyle(
            color: AppTheme.textSecondary, fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          )),
        Text(value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textPrimary,
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          )),
      ],
    );
  }

  // ─── Checkout Bar ─────────────────────────────────────────────────────────────
  Widget _buildCheckoutBar(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: AppTheme.secondary,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Text('\$${cart.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900,
                  color: AppTheme.accent,
                )),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _showCheckoutDialog(context, cart),
                icon: const Icon(Icons.lock_outline_rounded,
                    size: 16, color: Colors.white),
                label: const Text('Checkout',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Order Placed! 🎉'),
        content: Text(
          'Your order of \$${cart.total.toStringAsFixed(2)} has been placed successfully.\n\nYou will receive a confirmation shortly.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to home
            },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
