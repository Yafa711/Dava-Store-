// lib/presentation/screens/admin/admin_panel_screen.dart
// Admin Panel: shows only sections the current admin has permission for.
// Super Admin sees everything + team management tools.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import 'manage_admins_screen.dart';
import 'manage_offers_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(
                user.isSuperAdmin ? 'Super Admin' : 'Admin',
                style: const TextStyle(
                  color: AppTheme.accent, fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              backgroundColor: AppTheme.accent.withOpacity(0.1),
              side: const BorderSide(color: AppTheme.accent, width: 1),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          // ── Welcome header ──
          _buildWelcomeHeader(user),
          const SizedBox(height: 20),

          // ── Super Admin only: Team Management ─────────────────────────────
          if (user.isSuperAdmin) ...[
            _buildSectionTitle('Team Management'),
            const SizedBox(height: 10),
            _buildAdminTile(
              context,
              icon: Icons.admin_panel_settings_rounded,
              title: 'Manage Admins',
              subtitle: 'Add, remove & assign permissions to admins',
              badge: 'Super Admin Only',
              badgeColor: AppTheme.accent,
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ManageAdminsScreen())),
            ),
            const SizedBox(height: 20),
          ],

          // ── Permission-gated sections ──────────────────────────────────────
          _buildSectionTitle('Store Management'),
          const SizedBox(height: 10),

          // Products – requires permManageProducts
          if (user.canManageProducts)
            _buildAdminTile(
              context,
              icon: Icons.inventory_2_rounded,
              title: 'Manage Products',
              subtitle: 'Add, edit and organise products',
              onTap: () => Navigator.pushNamed(context, '/admin/products'),
            ),

          // Offers – requires permManageOffers
          if (user.canManageOffers) ...[
            const SizedBox(height: 10),
            _buildAdminTile(
              context,
              icon: Icons.local_offer_rounded,
              title: 'Manage Offers',
              subtitle: 'Create deals, coupons & promotions',
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ManageOffersScreen())),
            ),
          ],

          // Users – requires permManageUsers
          if (user.canManageUsers) ...[
            const SizedBox(height: 10),
            _buildAdminTile(
              context,
              icon: Icons.group_rounded,
              title: 'Manage Customers',
              subtitle: 'View and manage customer accounts',
              onTap: () => Navigator.pushNamed(context, '/admin/users'),
            ),
          ],

          // Orders – requires permManageOrders
          if (user.canManageOrders) ...[
            const SizedBox(height: 10),
            _buildAdminTile(
              context,
              icon: Icons.receipt_long_rounded,
              title: 'Manage Orders',
              subtitle: 'Process and track orders',
              onTap: () => Navigator.pushNamed(context, '/admin/orders'),
            ),
          ],

          // Analytics – requires permViewAnalytics
          if (user.canViewAnalytics) ...[
            const SizedBox(height: 10),
            _buildAdminTile(
              context,
              icon: Icons.bar_chart_rounded,
              title: 'Analytics',
              subtitle: 'Sales, revenue & traffic insights',
              onTap: () => Navigator.pushNamed(context, '/admin/analytics'),
            ),
          ],

          // Notifications – requires permSendNotifications
          if (user.canSendNotifications) ...[
            const SizedBox(height: 10),
            _buildAdminTile(
              context,
              icon: Icons.notifications_active_rounded,
              title: 'Push Notifications',
              subtitle: 'Send announcements & alerts',
              onTap: () => Navigator.pushNamed(context, '/admin/notifications'),
            ),
          ],

          // Categories – requires permManageCategories
          if (user.canManageCategories) ...[
            const SizedBox(height: 10),
            _buildAdminTile(
              context,
              icon: Icons.category_rounded,
              title: 'Categories',
              subtitle: 'Organise product categories',
              onTap: () => Navigator.pushNamed(context, '/admin/categories'),
            ),
          ],

          // Banners – requires permManageBanners
          if (user.canManageBanners) ...[
            const SizedBox(height: 10),
            _buildAdminTile(
              context,
              icon: Icons.image_rounded,
              title: 'Manage Banners',
              subtitle: 'Home page carousel banners',
              onTap: () => Navigator.pushNamed(context, '/admin/banners'),
            ),
          ],

          // No permissions warning
          if (!user.isSuperAdmin && user.permissionsList.isEmpty) ...[
            const SizedBox(height: 32),
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.lock_outline_rounded,
                    color: AppTheme.textMuted, size: 40),
                  const SizedBox(height: 12),
                  const Text('No Permissions Assigned',
                    style: AppTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'Contact your Super Admin to\nassign permissions to your account.',
                    style: AppTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(user) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: user.photoUrl.isNotEmpty
                ? NetworkImage(user.photoUrl) : null,
            backgroundColor: AppTheme.accent.withOpacity(0.2),
            child: user.photoUrl.isEmpty
                ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                    style: const TextStyle(color: AppTheme.accent,
                      fontWeight: FontWeight.w700))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, ${user.name.split(' ').first}',
                  style: AppTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  user.isSuperAdmin
                      ? 'Full access to all features'
                      : '${user.permissionsList.length} permission(s) assigned',
                  style: AppTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (!user.isSuperAdmin && user.permissionsList.isNotEmpty)
            Wrap(
              spacing: 4,
              children: user.permissionsList.take(2).map<Widget>((p) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppTheme.accent.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    AppConstants.permissionLabels[p]?.split(' ').last ?? p,
                    style: const TextStyle(
                      color: AppTheme.accent, fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
      style: const TextStyle(
        color: AppTheme.textMuted, fontSize: 11,
        fontWeight: FontWeight.w600, letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildAdminTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTheme.titleMedium),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? AppTheme.accent).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(badge,
                            style: TextStyle(
                              color: badgeColor ?? AppTheme.accent,
                              fontSize: 8, fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            )),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
              color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
