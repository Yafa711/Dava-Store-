// lib/presentation/screens/admin/manage_admins_screen.dart
// Super Admin can view, add, remove & granularly configure Admin permissions.
// Max 4 admin accounts enforced here and in AuthProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class ManageAdminsScreen extends StatefulWidget {
  const ManageAdminsScreen({super.key});
  @override
  State<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends State<ManageAdminsScreen> {
  List<UserModel> _admins   = [];
  bool            _loading  = true;
  String?         _error;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() { _loading = true; _error = null; });
    try {
      _admins = await context.read<AuthProvider>().fetchAdminUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text('Manage Admins'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text('${_admins.length}/${AppConstants.maxAdminAccounts}',
                style: const TextStyle(
                  color: AppTheme.accent, fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
              backgroundColor: AppTheme.accent.withOpacity(0.1),
              side: const BorderSide(color: AppTheme.accent),
            ),
          ),
        ],
      ),
      floatingActionButton: _admins.length < AppConstants.maxAdminAccounts
          ? FloatingActionButton.extended(
              onPressed: _showPromoteDialog,
              backgroundColor: AppTheme.accent,
              icon: const Icon(Icons.person_add_rounded, color: Colors.white),
              label: const Text('Add Admin',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : _error != null
              ? Center(child: Text(_error!, style: AppTheme.bodyMedium))
              : RefreshIndicator(
                  color: AppTheme.accent,
                  onRefresh: _loadAdmins,
                  child: _buildAdminList(),
                ),
    );
  }

  Widget _buildAdminList() {
    if (_admins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings_outlined,
              color: AppTheme.textMuted, size: 48),
            const SizedBox(height: 16),
            const Text('No admins yet', style: AppTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Tap + to promote a customer to admin.',
              style: AppTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      itemCount: _admins.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _adminCard(_admins[i]),
    );
  }

  Widget _adminCard(UserModel admin) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Admin info header ──
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.accent.withOpacity(0.15),
              backgroundImage: admin.photoUrl.isNotEmpty
                  ? NetworkImage(admin.photoUrl) : null,
              child: admin.photoUrl.isEmpty
                  ? Text(admin.name.isNotEmpty ? admin.name[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        color: AppTheme.accent, fontWeight: FontWeight.w700))
                  : null,
            ),
            title: Text(admin.name, style: AppTheme.titleMedium),
            subtitle: Text(admin.email, style: AppTheme.bodySmall),
            trailing: PopupMenuButton<String>(
              color: AppTheme.surface,
              icon: const Icon(Icons.more_vert_rounded,
                color: AppTheme.textMuted),
              onSelected: (action) {
                if (action == 'edit') _showPermissionsDialog(admin);
                if (action == 'revoke') _confirmRevoke(admin);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 16, color: AppTheme.textPrimary),
                    SizedBox(width: 8),
                    Text('Edit Permissions',
                      style: TextStyle(color: AppTheme.textPrimary)),
                  ])),
                const PopupMenuItem(value: 'revoke',
                  child: Row(children: [
                    Icon(Icons.person_remove_outlined, size: 16, color: AppTheme.error),
                    SizedBox(width: 8),
                    Text('Revoke Admin', style: TextStyle(color: AppTheme.error)),
                  ])),
              ],
            ),
          ),

          // ── Permissions chips ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Permissions',
                  style: TextStyle(
                    color: AppTheme.textMuted, fontSize: 10,
                    fontWeight: FontWeight.w600, letterSpacing: 1,
                  )),
                const SizedBox(height: 6),
                admin.permissionsList.isEmpty
                    ? const Text('No permissions assigned',
                        style: TextStyle(color: AppTheme.error, fontSize: 12))
                    : Wrap(
                        spacing: 6, runSpacing: 6,
                        children: admin.permissionsList.map((p) =>
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppTheme.accent.withOpacity(0.3)),
                            ),
                            child: Text(
                              AppConstants.permissionLabels[p] ?? p,
                              style: const TextStyle(
                                color: AppTheme.accent, fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ).toList(),
                      ),

                // Edit shortcut
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _showPermissionsDialog(admin),
                  icon: const Icon(Icons.tune_rounded, size: 14),
                  label: const Text('Configure Permissions'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Permission Dialog ────────────────────────────────────────────────────────
  // Core of the "Specific Individual Permissions" system.
  // Super Admin toggles each permission individually per Admin.
  void _showPermissionsDialog(UserModel admin) {
    final selected = List<String>.from(admin.permissionsList);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Permissions for ${admin.name.split(' ').first}'),
              const SizedBox(height: 4),
              const Text(
                'Toggle individual access rights below',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted,
                  fontWeight: FontWeight.w400),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppConstants.allPermissions.map((perm) {
                final label = AppConstants.permissionLabels[perm] ?? perm;
                final isEnabled = selected.contains(perm);
                return CheckboxListTile(
                  dense: true,
                  value: isEnabled,
                  onChanged: (v) {
                    setDialogState(() {
                      if (v == true) {
                        selected.add(perm);
                      } else {
                        selected.remove(perm);
                      }
                    });
                  },
                  title: Text(label,
                    style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 13)),
                  activeColor: AppTheme.accent,
                  checkColor: Colors.white,
                  side: const BorderSide(color: AppTheme.textMuted),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await context.read<AuthProvider>()
                    .updateAdminPermissions(admin.id, selected);
                _loadAdmins(); // Refresh list
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Permissions updated for ${admin.name.split(' ').first}'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPromoteDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Promote to Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the user\'s email to look them up and promote to Admin.',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'user@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // In production: look up user by email, then call promoteToAdmin
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature: look up user and promote')),
              );
            },
            child: const Text('Promote'),
          ),
        ],
      ),
    );
  }

  void _confirmRevoke(UserModel admin) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Admin Access'),
        content: Text(
          'Remove admin role from ${admin.name}? '
          'They will become a regular customer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().revokeAdmin(admin.id);
              _loadAdmins();
            },
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }
}
