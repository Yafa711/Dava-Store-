// lib/app.dart
// Root MyApp widget: wires providers and router together.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/offers_provider.dart';
import 'presentation/providers/products_provider.dart';

class DavaStoreApp extends StatelessWidget {
  const DavaStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth is listed first so other providers (if needed) can depend on it
        ChangeNotifierProvider<AuthProvider>.value(
          value: ServiceLocator.authProvider,
        ),
        ChangeNotifierProvider<ProductsProvider>.value(
          value: ServiceLocator.productsProvider,
        ),
        ChangeNotifierProvider<OffersProvider>.value(
          value: ServiceLocator.offersProvider,
        ),
        ChangeNotifierProvider<CartProvider>.value(
          value: ServiceLocator.cartProvider,
        ),
      ],
      child: Builder(
        builder: (context) {
          // Build router once; it listens to AuthProvider for redirects
          final router = AppRouter.createRouter(
            context.read<AuthProvider>(),
          );

          return MaterialApp.router(
            title:            'DAVA Store',
            debugShowCheckedModeBanner: false,
            theme:            AppTheme.darkTheme,
            routerConfig:     router,
          );
        },
      ),
    );
  }
}
