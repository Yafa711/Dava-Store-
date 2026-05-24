// lib/data/models/user_model.dart
// Firestore ↔ Domain mapping for User

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/constants/app_constants.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.photoUrl,
    required super.role,
    super.permissionsList,
    required super.createdAt,
    super.lastLoginAt,
    super.isActive,
  });

  // ─── Firestore → Model ───────────────────────────────────────────────────────
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id:    doc.id,
      email: data['email'] ?? '',
      name:  data['name']  ?? '',
      photoUrl: data['photo_url'] ?? '',
      role:  data['role'] ?? AppConstants.roleCustomer,
      // permissions_list is stored as a Firestore array of strings
      permissionsList: List<String>.from(data['permissions_list'] ?? []),
      createdAt:   (data['created_at'] as Timestamp?)?.toDate()   ?? DateTime.now(),
      lastLoginAt: (data['last_login_at'] as Timestamp?)?.toDate(),
      isActive: data['is_active'] ?? true,
    );
  }

  // ─── Map → Model (from local cache) ─────────────────────────────────────────
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id:    map['id'] ?? '',
      email: map['email'] ?? '',
      name:  map['name']  ?? '',
      photoUrl: map['photo_url'] ?? '',
      role:  map['role'] ?? AppConstants.roleCustomer,
      permissionsList: List<String>.from(map['permissions_list'] ?? []),
      createdAt:   DateTime.fromMillisecondsSinceEpoch(map['created_at'] ?? 0),
      lastLoginAt: map['last_login_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['last_login_at'])
        : null,
      isActive: map['is_active'] ?? true,
    );
  }

  // ─── Model → Firestore Map ───────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'email':            email,
      'name':             name,
      'photo_url':        photoUrl,
      'role':             role,
      'permissions_list': permissionsList,
      'created_at':       Timestamp.fromDate(createdAt),
      'last_login_at':    lastLoginAt != null
        ? Timestamp.fromDate(lastLoginAt!) : null,
      'is_active':        isActive,
    };
  }

  // ─── Model → Cache Map ───────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id':               id,
      'email':            email,
      'name':             name,
      'photo_url':        photoUrl,
      'role':             role,
      'permissions_list': permissionsList,
      'created_at':       createdAt.millisecondsSinceEpoch,
      'last_login_at':    lastLoginAt?.millisecondsSinceEpoch,
      'is_active':        isActive,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id:             entity.id,
      email:          entity.email,
      name:           entity.name,
      photoUrl:       entity.photoUrl,
      role:           entity.role,
      permissionsList: entity.permissionsList,
      createdAt:      entity.createdAt,
      lastLoginAt:    entity.lastLoginAt,
      isActive:       entity.isActive,
    );
  }
}
