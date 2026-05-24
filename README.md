# DAVA Store 🛍️

**Premium Flutter E-Commerce App** — Clean Architecture · Provider · Firebase · Glassmorphism UI

---

## 🎨 Design System

| Token | Value | Use |
|---|---|---|
| Primary | `#182421` | App background, deep dark green |
| Secondary | `#18242C` | Bottom nav, cards |
| Accent | `#D1848C` | CTAs, badges, highlights |
| Glass White | `#FFFFFF14` | Glassmorphism surfaces |

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/      app_constants.dart   – colours, strings, permissions
│   ├── theme/          app_theme.dart        – ThemeData + GlassContainer
│   ├── router/         app_router.dart       – GoRouter + auth guards
│   └── di/             service_locator.dart  – dependency wiring
│
├── domain/
│   └── entities/
│       ├── user_entity.dart      – role helpers, hasPermission()
│       ├── offer_entity.dart     – isExpired, isLive, expiryLabel
│       └── product_entity.dart
│
├── data/
│   ├── models/                   – Firestore ↔ domain mapping
│   │   ├── user_model.dart
│   │   ├── offer_model.dart
│   │   └── product_model.dart
│   └── datasources/remote/
│       ├── auth_service.dart     – Google Sign-In + role upsert
│       ├── sync_service.dart     – refreshData(), real-time listeners
│       └── notification_service.dart – FCM + local notifications
│
└── presentation/
    ├── providers/
    │   ├── auth_provider.dart    – auth state + admin management
    │   ├── products_provider.dart – search, filter, sort
    │   ├── offers_provider.dart
    │   └── cart_provider.dart
    └── screens/
        ├── auth/        auth_screen.dart
        ├── home/        home_screen.dart    – carousel, grid, categories
        ├── product/     product_detail_screen.dart
        ├── cart/        cart_screen.dart
        ├── offers/      offers_screen.dart
        ├── profile/     profile_screen.dart
        ├── admin/
        │   ├── admin_panel_screen.dart     – permission-gated sections
        │   ├── manage_admins_screen.dart   – granular per-admin permissions
        │   └── manage_offers_screen.dart
        └── main_scaffold.dart              – bottom nav
```

---

## 🔐 Role & Permission System

### Roles
| Role | Access |
|---|---|
| `super_admin` | All features + team management |
| `admin` | Only sections assigned by Super Admin |
| `customer` | Shopping features only |

### Granular Permissions (per Admin)
Each Admin account can be given **any subset** of these permissions independently:

| Permission Key | Label |
|---|---|
| `manage_products` | Manage Products |
| `manage_offers` | Manage Offers & Deals |
| `manage_users` | Manage Customers |
| `manage_orders` | Manage Orders |
| `view_analytics` | View Analytics |
| `send_notifications` | Send Notifications |
| `manage_categories` | Manage Categories |
| `manage_banners` | Manage Banners |

**Example:**
- Admin A → `manage_offers` only
- Admin B → `manage_users` + `manage_orders`
- Admin C → `view_analytics` + `send_notifications`

### Enforcement
1. **Firestore Rules** (`firestore.rules`) — server-side, cannot be bypassed
2. **UI gating** — `AdminPanelScreen` only renders tiles the user has permission for
3. **`UserEntity.hasPermission(perm)`** — client-side check used throughout

---

## ⚡ Smart Sync (`SyncService`)

```dart
syncService.refreshData()
  // 1. Batch-marks expired offers as is_active=false in Firestore
  // 2. Fetches fresh products & offers
  // 3. Saves to SharedPreferences cache
  // 4. Broadcasts via streams to all listening providers
```

- **Real-time Firestore listeners** keep the UI live without polling
- **Periodic sync** every 30 min catches edge cases
- **Offline fallback** emits cached data if network fails

---

## 🚀 Setup Guide

### 1. Prerequisites
```bash
flutter --version   # >= 3.0.0
```

### 2. Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project: `dava-store`
3. Enable **Authentication** → Sign-in method → **Google**
4. Enable **Cloud Firestore** (start in test mode, then apply `firestore.rules`)
5. Enable **Cloud Messaging** (for push notifications)

### 3. FlutterFire Configuration
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_PROJECT_ID
# This auto-generates lib/firebase_options.dart
```

### 4. Android: Add SHA-1 fingerprint (required for Google Sign-In)
```bash
cd android
./gradlew signingReport
# Copy the SHA-1 and add it in Firebase Console → Project Settings → Android app
```

### 5. Install dependencies
```bash
flutter pub get
```

### 6. Set Super Admin
After your first login, manually set your role in Firestore:
```
Collection: users
Document:   YOUR_UID
Field:      role = "super_admin"
```

### 7. Run
```bash
flutter run
```

---

## 🔔 Push Notifications

Push notifications flow:
1. On login, FCM token saved to `users/{uid}.fcm_token`
2. Admin creates a notification doc in `notifications/` collection
3. A Cloud Function (deploy separately) fans out FCM messages to target tokens

---

## 📦 Firestore Collections

| Collection | Description |
|---|---|
| `users` | User profiles with role + permissions_list |
| `products` | Product catalogue |
| `offers` | Deals with expiry_date |
| `orders` | Customer orders |
| `categories` | Product categories |
| `notifications` | Push notification records |
| `admin_settings` | Global store configuration |

---

## 🛡️ Security Rules

Deploy Firestore rules:
```bash
firebase deploy --only firestore:rules
```

Rules enforce:
- Users can only read/write their own data
- Admins need the specific `permission_key` to modify each collection
- Super Admins bypass all permission checks
- Products & categories are publicly readable

---

## 📱 Features Checklist

- [x] Google Sign-In (exclusive)
- [x] Role system: Super Admin / Admin / Customer
- [x] Granular per-admin permissions (8 independent permissions)
- [x] Super Admin limited to 4 Admin accounts
- [x] SyncService with refreshData() + expired offer cleanup
- [x] Real-time Firestore listeners
- [x] Local caching (SharedPreferences)
- [x] High-density 2-column product GridView
- [x] Visual Search (camera/gallery picker)
- [x] Push Notifications (FCM)
- [x] Glassmorphism UI throughout
- [x] Banner Carousel
- [x] Category filtering
- [x] Product sort (price, rating, newest)
- [x] Cart with coupon validation
- [x] Admin Panel (permission-gated)
- [x] Manage Admins (Super Admin)
- [x] Manage Offers (create/deactivate/delete)
- [x] Firestore security rules
- [x] Clean Architecture (entity / model / service / provider)

---

*Built with Flutter · Firebase · Provider · Clean Architecture*
