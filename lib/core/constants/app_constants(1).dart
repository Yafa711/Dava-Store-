// lib/core/constants/app_constants.dart
// Central constants for DAVA Store - colors, strings, config

class AppConstants {
  // ─── App Identity ───────────────────────────────────────────────────────────
  static const String appName = 'DAVA Store';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Premium Shopping Experience';

  // ─── Color Hex Values ────────────────────────────────────────────────────────
  static const int primaryColorHex    = 0xFF182421; // Deep dark green
  static const int secondaryColorHex  = 0xFF18242C; // Dark navy
  static const int accentColorHex     = 0xFFD1848C; // Rose accent
  static const int surfaceColorHex    = 0xFF1E2D2A;
  static const int cardColorHex       = 0xFF243330;
  static const int dividerColorHex    = 0xFF2E4440;

  // ─── Firestore Collections ───────────────────────────────────────────────────
  static const String usersCollection    = 'users';
  static const String productsCollection = 'products';
  static const String offersCollection   = 'offers';
  static const String ordersCollection   = 'orders';
  static const String categoriesCollection = 'categories';
  static const String cartCollection     = 'carts';
  static const String notificationsCollection = 'notifications';
  static const String adminSettingsCollection = 'admin_settings';

  // ─── User Roles ──────────────────────────────────────────────────────────────
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin      = 'admin';
  static const String roleCustomer   = 'customer';

  // ─── Admin Permissions (Granular) ────────────────────────────────────────────
  // Each permission key maps to a specific Admin capability
  static const String permManageProducts    = 'manage_products';
  static const String permManageOffers      = 'manage_offers';
  static const String permManageUsers       = 'manage_users';
  static const String permManageOrders      = 'manage_orders';
  static const String permViewAnalytics     = 'view_analytics';
  static const String permSendNotifications = 'send_notifications';
  static const String permManageCategories  = 'manage_categories';
  static const String permManageBanners     = 'manage_banners';

  // Full list of all assignable permissions
  static const List<String> allPermissions = [
    permManageProducts,
    permManageOffers,
    permManageUsers,
    permManageOrders,
    permViewAnalytics,
    permSendNotifications,
    permManageCategories,
    permManageBanners,
  ];

  // Human-readable permission labels
  static const Map<String, String> permissionLabels = {
    permManageProducts:    'Manage Products',
    permManageOffers:      'Manage Offers & Deals',
    permManageUsers:       'Manage Customers',
    permManageOrders:      'Manage Orders',
    permViewAnalytics:     'View Analytics',
    permSendNotifications: 'Send Notifications',
    permManageCategories:  'Manage Categories',
    permManageBanners:     'Manage Banners',
  };

  // ─── Super Admin Limits ──────────────────────────────────────────────────────
  static const int maxAdminAccounts = 4; // Super Admin can create max 4 Admins

  // ─── Cache Keys ──────────────────────────────────────────────────────────────
  static const String cacheKeyProducts    = 'cached_products';
  static const String cacheKeyOffers      = 'cached_offers';
  static const String cacheKeyCategories  = 'cached_categories';
  static const String cacheKeyUserProfile = 'cached_user_profile';
  static const String cacheKeyLastSync    = 'last_sync_timestamp';

  // ─── Cache Duration ──────────────────────────────────────────────────────────
  static const int cacheDurationMinutes = 30;

  // ─── Pagination ──────────────────────────────────────────────────────────────
  static const int productsPerPage = 20;
  static const int ordersPerPage   = 15;
  static const int usersPerPage    = 25;

  // ─── Animation Durations ─────────────────────────────────────────────────────
  static const Duration animFast   = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow   = Duration(milliseconds: 600);

  // ─── Border Radius ───────────────────────────────────────────────────────────
  static const double radiusSm  = 8.0;
  static const double radiusMd  = 12.0;
  static const double radiusLg  = 16.0;
  static const double radiusXl  = 24.0;
  static const double radiusXxl = 32.0;

  // ─── Spacing ─────────────────────────────────────────────────────────────────
  static const double spacingXs  = 4.0;
  static const double spacingSm  = 8.0;
  static const double spacingMd  = 16.0;
  static const double spacingLg  = 24.0;
  static const double spacingXl  = 32.0;
  static const double spacingXxl = 48.0;

  // ─── Grid ────────────────────────────────────────────────────────────────────
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.72;
  static const double gridSpacing = 12.0;
}
