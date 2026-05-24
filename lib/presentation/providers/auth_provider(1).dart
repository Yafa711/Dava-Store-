// lib/presentation/providers/auth_provider.dart
// Manages auth state: Firebase user + Firestore UserModel with role & permissions

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/remote/auth_service.dart';
import '../../data/models/user_model.dart';
import '../../core/constants/app_constants.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus  _status     = AuthStatus.unknown;
  UserModel?  _currentUser;
  String?     _errorMessage;
  bool        _isLoading  = false;

  // Real-time profile listener subscription
  StreamSubscription? _profileSubscription;

  AuthProvider({required AuthService authService})
      : _authService = authService {
    _init();
  }

  // ─── Getters ──────────────────────────────────────────────────────────────────
  AuthStatus get status      => _status;
  UserModel? get currentUser => _currentUser;
  String?    get errorMessage => _errorMessage;
  bool       get isLoading   => _isLoading;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isSuperAdmin    => _currentUser?.isSuperAdmin ?? false;
  bool get isAdmin         => _currentUser?.isAdmin ?? false;
  bool get isCustomer      => _currentUser?.isCustomer ?? false;

  // Permission checks for UI gating
  bool hasPermission(String permission) =>
      _currentUser?.hasPermission(permission) ?? false;

  // ─── Init ─────────────────────────────────────────────────────────────────────
  void _init() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _status      = AuthStatus.unauthenticated;
        _currentUser = null;
        _profileSubscription?.cancel();
        notifyListeners();
      } else {
        // Listen to Firestore user doc in real-time so role/permission changes
        // propagate instantly without re-login
        _profileSubscription?.cancel();
        _profileSubscription = _authService
            .userProfileStream(firebaseUser.uid)
            .listen((userModel) {
              _currentUser = userModel;
              _status = userModel != null
                  ? AuthStatus.authenticated
                  : AuthStatus.unauthenticated;
              notifyListeners();
            });
      }
    });
  }

  // ─── Google Sign In ──────────────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    try {
      _isLoading    = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signInWithGoogle();
      _status      = AuthStatus.authenticated;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status       = AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = 'Sign-in failed. Please try again.';
      _status       = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Sign Out ────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _status      = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─── Admin Management (Super Admin) ─────────────────────────────────────────

  /// Promotes a user to admin with selected permissions.
  /// Validates max admin limit before promoting.
  Future<bool> promoteToAdmin(String uid, List<String> permissions) async {
    final admins = await _authService.fetchAdminUsers();
    if (admins.length >= AppConstants.maxAdminAccounts) {
      _errorMessage =
          'Maximum of ${AppConstants.maxAdminAccounts} admin accounts reached.';
      notifyListeners();
      return false;
    }
    await _authService.promoteToAdmin(uid, permissions);
    return true;
  }

  /// Updates individual admin's permissions (granular permission assignment).
  Future<void> updateAdminPermissions(
    String adminUid,
    List<String> permissions,
  ) async {
    await _authService.updateAdminPermissions(adminUid, permissions);
  }

  /// Revokes admin → customer for a given user.
  Future<void> revokeAdmin(String adminUid) async {
    await _authService.revokeAdmin(adminUid);
  }

  Future<List<UserModel>> fetchAdminUsers() =>
      _authService.fetchAdminUsers();

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}
