// lib/presentation/screens/main_scaffold.dart
// Root scaffold: bottom nav bar routing between Home, Offers, Cart, Profile/Admin

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import 'home/home_screen.dart';
import 'offers/offers_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';
import 'admin/admin_panel_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _customerPages = const [
    HomeScreen(),
    OffersScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    // For admins & super admins, show admin panel as a tab
    final isPrivilegedUser =
        user != null && (user.isSuperAdmin || user.isAdmin);

    final pages = isPrivilegedUser
        ? [
            const HomeScreen(),
            const OffersScreen(),
            const CartScreen(),
            const AdminPanelScreen(),
            const ProfileScreen(),
          ]
        : _customerPages;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNav(isPrivilegedUser),
    );
  }

  Widget _buildBottomNav(bool isPrivilegedUser) {
    return Consumer<CartProvider>(
      builder: (_, cart, __) {
        final items = isPrivilegedUser
            ? [
                _navItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
                _navItem(Icons.local_offer_rounded,
                    Icons.local_offer_outlined, 'Deals'),
                _navItemCart(cart.itemCount),
                _navItem(Icons.admin_panel_settings_rounded,
                    Icons.admin_panel_settings_outlined, 'Admin'),
                _navItem(Icons.person_rounded, Icons.person_outlined, 'Profile'),
              ]
            : [
                _navItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
                _navItem(Icons.local_offer_rounded,
                    Icons.local_offer_outlined, 'Deals'),
                _navItemCart(cart.itemCount),
                _navItem(Icons.person_rounded, Icons.person_outlined, 'Profile'),
              ];

        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.secondary,
            border: Border(top: BorderSide(color: AppTheme.divider)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: items.asMap().entries.map((e) {
                  final selected = _currentIndex == e.key;
                  return GestureDetector(
                    onTap: () => setState(() => _currentIndex = e.key),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: AppConstants.animFast,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.accent.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusSm),
                      ),
                      child: e.value,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _navItem(IconData activeIcon, IconData inactiveIcon, String label) {
    return Builder(builder: (context) {
      final selected = _currentIndex ==
          (context.findAncestorWidgetOfExactType<Row>()
                  ?.children
                  .indexWhere((w) => w is GestureDetector) ?? 0);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _currentIndex ==
                    (context
                            .findAncestorWidgetOfExactType<Row>()
                            ?.children
                            .length ??
                        0)
                ? activeIcon
                : inactiveIcon,
            color: AppTheme.textMuted,
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(label,
            style: const TextStyle(
              color: AppTheme.textMuted, fontSize: 10,
            )),
        ],
      );
    });
  }

  Widget _navItemCart(int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined,
                color: AppTheme.textMuted, size: 22),
            const SizedBox(height: 2),
            const Text('Cart',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
          ],
        ),
        if (count > 0)
          Positioned(
            top: -4, right: -8,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(
                color: AppTheme.accent, shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('$count',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 9,
                    fontWeight: FontWeight.w800,
                  )),
              ),
            ),
          ),
      ],
    );
  }
}

// Cleaner approach — rewrite the bottom nav using proper index-aware widgets
class _BottomNavItem extends StatelessWidget {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool selected;
  final int? badgeCount;

  const _BottomNavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.selected,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              selected ? activeIcon : inactiveIcon,
              color: selected ? AppTheme.accent : AppTheme.textMuted,
              size: 24,
            ),
            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                top: -4, right: -8,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(
                    color: AppTheme.accent, shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('$badgeCount',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 9,
                        fontWeight: FontWeight.w800,
                      )),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        Text(label,
          style: TextStyle(
            color: selected ? AppTheme.accent : AppTheme.textMuted,
            fontSize: 10,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          )),
      ],
    );
  }
}

// ─── Proper Implementation of MainScaffold with clean nav ────────────────────
class MainScaffoldV2 extends StatefulWidget {
  const MainScaffoldV2({super.key});
  @override
  State<MainScaffoldV2> createState() => _MainScaffoldV2State();
}

class _MainScaffoldV2State extends State<MainScaffoldV2> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isPrivileged = user != null && (user.isSuperAdmin || user.isAdmin);
    final cart = context.watch<CartProvider>();

    final List<Map<String, dynamic>> navConfig = [
      {
        'label': 'Home',
        'active': Icons.home_rounded,
        'inactive': Icons.home_outlined,
        'page': const HomeScreen(),
      },
      {
        'label': 'Deals',
        'active': Icons.local_offer_rounded,
        'inactive': Icons.local_offer_outlined,
        'page': const OffersScreen(),
      },
      {
        'label': 'Cart',
        'active': Icons.shopping_bag_rounded,
        'inactive': Icons.shopping_bag_outlined,
        'page': const CartScreen(),
        'badge': cart.itemCount,
      },
      if (isPrivileged) {
        'label': 'Admin',
        'active': Icons.admin_panel_settings_rounded,
        'inactive': Icons.admin_panel_settings_outlined,
        'page': const AdminPanelScreen(),
      },
      {
        'label': 'Profile',
        'active': Icons.person_rounded,
        'inactive': Icons.person_outlined,
        'page': const ProfileScreen(),
      },
    ];

    return Scaffold(
      body: IndexedStack(
        index: _idx,
        children: navConfig.map((c) => c['page'] as Widget).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.secondary,
          border: Border(top: BorderSide(color: AppTheme.divider, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navConfig.asMap().entries.map((e) {
                final selected = _idx == e.key;
                final badge    = e.value['badge'] as int?;
                return GestureDetector(
                  onTap: () => setState(() => _idx = e.key),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: _BottomNavItem(
                      activeIcon:   e.value['active']   as IconData,
                      inactiveIcon: e.value['inactive'] as IconData,
                      label:        e.value['label']    as String,
                      selected:     selected,
                      badgeCount:   badge,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
