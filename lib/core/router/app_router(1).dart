// lib/core/router/app_router.dart
// GoRouter config: redirects unauthenticated users to /auth,
// admin routes are guarded by role checks.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/auth_screen.dart';
import '../../presentation/screens/main_scaffold.dart';
import '../../presentation/screens/product/product_detail_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../domain/entities/product_entity.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      debugLogDiagnostics: true,
      refreshListenable: authProvider,

      // ── Redirect logic ──────────────────────────────────────────────────────
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/auth';

        // Not logged in → go to /auth
        if (!isLoggedIn && !isAuthRoute) return '/auth';

        // Logged in but on /auth → go to /home
        if (isLoggedIn && isAuthRoute) return '/';

        return null; // No redirect needed
      },

      routes: [
        // ── Auth ───────────────────────────────────────────────────────────────
        GoRoute(
          path: '/auth',
          name: 'auth',
          builder: (_, __) => const AuthScreen(),
        ),

        // ── Main Shell ─────────────────────────────────────────────────────────
        GoRoute(
          path: '/',
          name: 'home',
          builder: (_, __) => const MainScaffoldV2(),
          routes: [
            // Product detail
            GoRoute(
              path: 'product',
              name: 'product',
              builder: (context, state) {
                final product = state.extra as ProductEntity;
                return ProductDetailScreen(product: product);
              },
            ),

            // Cart (can also be deep-linked)
            GoRoute(
              path: 'cart',
              name: 'cart',
              builder: (_, __) => const CartScreen(),
            ),

            // Admin routes (guarded inside their screens via hasPermission)
            GoRoute(
              path: 'admin/products',
              name: 'admin-products',
              builder: (_, __) => _guardAdmin(
                context: _,
                child: const _PlaceholderScreen('Manage Products'),
              ),
            ),
            GoRoute(
              path: 'admin/users',
              name: 'admin-users',
              builder: (_, __) => _guardAdmin(
                context: _,
                child: const _PlaceholderScreen('Manage Users'),
              ),
            ),
            GoRoute(
              path: 'admin/orders',
              name: 'admin-orders',
              builder: (_, __) => _guardAdmin(
                context: _,
                child: const _PlaceholderScreen('Manage Orders'),
              ),
            ),
            GoRoute(
              path: 'admin/analytics',
              name: 'admin-analytics',
              builder: (_, __) => _guardAdmin(
                context: _,
                child: const _PlaceholderScreen('Analytics'),
              ),
            ),
            GoRoute(
              path: 'admin/notifications',
              name: 'admin-notifications',
              builder: (_, __) => _guardAdmin(
                context: _,
                child: const _PlaceholderScreen('Send Notifications'),
              ),
            ),
            GoRoute(
              path: 'admin/categories',
              name: 'admin-categories',
              builder: (_, __) => _guardAdmin(
                context: _,
                child: const _PlaceholderScreen('Manage Categories'),
              ),
            ),
            GoRoute(
              path: 'admin/banners',
              name: 'admin-banners',
              builder: (_, __) => _guardAdmin(
                context: _,
                child: const _PlaceholderScreen('Manage Banners'),
              ),
            ),
          ],
        ),
      ],

      errorBuilder: (_, state) => Scaffold(
        backgroundColor: const Color(0xFF182421),
        body: Center(
          child: Text('Page not found: ${state.error}',
            style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  /// Checks admin/super-admin role; shows AccessDenied screen otherwise.
  static Widget _guardAdmin({
    required BuildContext context,
    required Widget child,
  }) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser?.isAdmin == true ||
        auth.currentUser?.isSuperAdmin == true) {
      return child;
    }
    return const _AccessDeniedScreen();
  }
}

// ─── Placeholder screen for routes not yet fully implemented ─────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF182421),
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_rounded,
                color: Color(0xFFD1848C), size: 52),
            const SizedBox(height: 16),
            Text(title,
              style: const TextStyle(
                color: Color(0xFFF0EDE8), fontSize: 20,
                fontWeight: FontWeight.w700,
              )),
            const SizedBox(height: 8),
            const Text('This section is coming soon',
              style: TextStyle(color: Color(0xFFB0ADA8))),
          ],
        ),
      ),
    );
  }
}

// ─── Access Denied ────────────────────────────────────────────────────────────
class _AccessDeniedScreen extends StatelessWidget {
  const _AccessDeniedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF182421),
      appBar: AppBar(title: const Text('Access Denied')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded,
                color: Color(0xFFEF5350), size: 52),
            const SizedBox(height: 16),
            const Text('Access Denied',
              style: TextStyle(
                color: Color(0xFFF0EDE8), fontSize: 20,
                fontWeight: FontWeight.w700,
              )),
            const SizedBox(height: 8),
            const Text('You do not have permission to view this page.',
              style: TextStyle(color: Color(0xFFB0ADA8))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
