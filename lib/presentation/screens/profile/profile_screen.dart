// lib/presentation/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.secondary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
                child: Stack(
                  children: [
                    // Glow
                    Positioned(
                      top: -40, right: -40,
                      child: Container(
                        width: 200, height: 200,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.accentRadial,
                        ),
                      ),
                    ),
                    // Avatar
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: user.photoUrl.isNotEmpty
                                ? NetworkImage(user.photoUrl)
                                : null,
                            backgroundColor: AppTheme.accent.withOpacity(0.2),
                            child: user.photoUrl.isEmpty
                                ? Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 28, fontWeight: FontWeight.w800,
                                      color: AppTheme.accent,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(user.name, style: AppTheme.headlineMedium),
                          const SizedBox(height: 4),
                          _roleBadge(user.role),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account info card
                  _sectionCard([
                    _infoRow(Icons.email_outlined, 'Email', user.email),
                    _infoRow(Icons.badge_outlined, 'Role',
                        user.role.replaceAll('_', ' ').toUpperCase()),
                    if (user.isAdmin && user.permissionsList.isNotEmpty)
                      _infoRow(Icons.security_outlined, 'Permissions',
                          '${user.permissionsList.length} assigned'),
                    _infoRow(Icons.calendar_today_outlined, 'Member Since',
                        _formatDate(user.createdAt)),
                  ]),
                  const SizedBox(height: 16),

                  // Permissions (for admins)
                  if (user.isAdmin && user.permissionsList.isNotEmpty) ...[
                    const Text('Your Permissions',
                      style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 11,
                        fontWeight: FontWeight.w600, letterSpacing: 1.5,
                      )),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: user.permissionsList.map((p) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        child: Text(
                          AppConstants.permissionLabels[p] ?? p,
                          style: const TextStyle(
                            color: AppTheme.accent, fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Settings
                  const Text('Settings',
                    style: TextStyle(
                      color: AppTheme.textMuted, fontSize: 11,
                      fontWeight: FontWeight.w600, letterSpacing: 1.5,
                    )),
                  const SizedBox(height: 8),
                  _sectionCard([
                    _menuItem(context, Icons.notifications_outlined,
                        'Notifications', () {}),
                    _menuItem(context, Icons.location_on_outlined,
                        'Addresses', () {}),
                    _menuItem(context, Icons.payment_outlined,
                        'Payment Methods', () {}),
                    _menuItem(context, Icons.help_outline_rounded,
                        'Help & Support', () {}),
                    _menuItem(context, Icons.privacy_tip_outlined,
                        'Privacy Policy', () {}),
                  ]),
                  const SizedBox(height: 16),

                  // Sign Out
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmSignOut(context),
                      icon: const Icon(Icons.logout_rounded,
                          color: AppTheme.error, size: 18),
                      label: const Text('Sign Out',
                        style: TextStyle(color: AppTheme.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMd),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleBadge(String role) {
    Color color;
    String label;
    switch (role) {
      case AppConstants.roleSuperAdmin:
        color = const Color(0xFFFFB74D); label = '★ Super Admin'; break;
      case AppConstants.roleAdmin:
        color = AppTheme.accent; label = '⬡ Admin'; break;
      default:
        color = AppTheme.info; label = 'Customer';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
        style: TextStyle(
          color: color, fontSize: 11, fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        )),
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        children: children.asMap().entries.map((e) => Column(
          children: [
            e.value,
            if (e.key < children.length - 1)
              const Divider(color: AppTheme.divider, height: 1, indent: 54),
          ],
        )).toList(),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 11,
                )),
              const SizedBox(height: 2),
              Text(value, style: AppTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title,
      VoidCallback onTap) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: AppTheme.textSecondary, size: 20),
      title: Text(title, style: AppTheme.titleMedium),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppTheme.textMuted, size: 18),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
