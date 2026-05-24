// lib/domain/entities/user_entity.dart
// Pure domain entity – no Firebase/JSON dependency

import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String photoUrl;
  final String role; // 'super_admin' | 'admin' | 'customer'
  final List<String> permissionsList; // Granular permissions for admin roles
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl = '',
    required this.role,
    this.permissionsList = const [],
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });

  // ─── Role Helpers ─────────────────────────────────────────────────────────────
  bool get isSuperAdmin => role == AppConstants.roleSuperAdmin;
  bool get isAdmin      => role == AppConstants.roleAdmin;
  bool get isCustomer   => role == AppConstants.roleCustomer;

  /// Checks if this user (admin) has a specific granular permission.
  /// Super Admin always has all permissions.
  bool hasPermission(String permission) {
    if (isSuperAdmin) return true;
    return permissionsList.contains(permission);
  }

  bool get canManageProducts    => hasPermission(AppConstants.permManageProducts);
  bool get canManageOffers      => hasPermission(AppConstants.permManageOffers);
  bool get canManageUsers       => hasPermission(AppConstants.permManageUsers);
  bool get canManageOrders      => hasPermission(AppConstants.permManageOrders);
  bool get canViewAnalytics     => hasPermission(AppConstants.permViewAnalytics);
  bool get canSendNotifications => hasPermission(AppConstants.permSendNotifications);
  bool get canManageCategories  => hasPermission(AppConstants.permManageCategories);
  bool get canManageBanners     => hasPermission(AppConstants.permManageBanners);

  UserEntity copyWith({
    String? id, String? email, String? name, String? photoUrl,
    String? role, List<String>? permissionsList,
    DateTime? createdAt, DateTime? lastLoginAt, bool? isActive,
  }) {
    return UserEntity(
      id:              id              ?? this.id,
      email:           email           ?? this.email,
      name:            name            ?? this.name,
      photoUrl:        photoUrl        ?? this.photoUrl,
      role:            role            ?? this.role,
      permissionsList: permissionsList ?? this.permissionsList,
      createdAt:       createdAt       ?? this.createdAt,
      lastLoginAt:     lastLoginAt     ?? this.lastLoginAt,
      isActive:        isActive        ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, email, role, permissionsList, isActive];
}
