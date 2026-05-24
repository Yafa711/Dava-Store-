// lib/data/datasources/remote/auth_service.dart
// Google Sign-In + Firebase Auth + Firestore role assignment

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth      _auth;
  final GoogleSignIn      _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthService({
    required FirebaseAuth      auth,
    required GoogleSignIn      googleSignIn,
    required FirebaseFirestore firestore,
  })  : _auth         = auth,
        _googleSignIn = googleSignIn,
        _firestore    = firestore;

  // ─── Auth State Stream ───────────────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User?         get currentFirebaseUser => _auth.currentUser;

  // ─── Google Sign-In Flow ─────────────────────────────────────────────────────
  /// Complete Google Sign-In → Firebase Auth → Role-check flow:
  ///  1. Opens Google account chooser
  ///  2. Gets Google ID token
  ///  3. Signs in to Firebase with Google credential
  ///  4. Creates/updates Firestore user document
  ///  5. Returns full UserModel with role + permissions
  Future<UserModel> signInWithGoogle() async {
    // ── Step 1: Trigger Google sign-in UI ────────────────────────────────────
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw AuthException('Sign-in cancelled by user');

    // ── Step 2: Get Google authentication tokens ─────────────────────────────
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // ── Step 3: Create Firebase credential ───────────────────────────────────
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken:     googleAuth.idToken,
    );

    // ── Step 4: Sign in to Firebase ──────────────────────────────────────────
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final User firebaseUser = userCredential.user!;

    // ── Step 5: Upsert Firestore user document ────────────────────────────────
    final userModel = await _upsertUserDocument(
      uid:      firebaseUser.uid,
      email:    firebaseUser.email ?? '',
      name:     firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL ?? '',
    );

    return userModel;
  }

  // ─── Upsert Firestore User Document ─────────────────────────────────────────
  /// Creates the user doc on first login; updates lastLoginAt on subsequent
  /// logins. Role defaults to 'customer' unless already set in Firestore.
  Future<UserModel> _upsertUserDocument({
    required String uid,
    required String email,
    required String name,
    required String photoUrl,
  }) async {
    final docRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid);

    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      // ── First login: create user with default 'customer' role ───────────────
      final now = DateTime.now();
      final newUser = UserModel(
        id:             uid,
        email:          email,
        name:           name,
        photoUrl:       photoUrl,
        role:           AppConstants.roleCustomer, // Default role
        permissionsList: [],                        // No permissions by default
        createdAt:      now,
        lastLoginAt:    now,
        isActive:       true,
      );
      await docRef.set(newUser.toFirestore());
      return newUser;
    } else {
      // ── Subsequent login: update lastLoginAt, keep existing role ─────────────
      await docRef.update({
        'last_login_at': Timestamp.fromDate(DateTime.now()),
        'photo_url':     photoUrl, // Keep photo in sync with Google
        'name':          name,
      });
      return UserModel.fromFirestore(docSnap);
    }
  }

  // ─── Fetch User Profile ──────────────────────────────────────────────────────
  /// Fetches fresh UserModel from Firestore (includes role + permissions).
  Future<UserModel?> fetchUserProfile(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // ─── Real-time User Profile ──────────────────────────────────────────────────
  Stream<UserModel?> userProfileStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // ─── Sign Out ────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ─── Admin Management (Super Admin only) ────────────────────────────────────

  /// Assigns a role to a user. Only callable by Super Admin.
  Future<void> assignRole(String uid, String newRole) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'role': newRole});
  }

  /// Updates the granular permissions list for an admin user.
  /// This is the core of the "Specific Individual Permissions" system.
  ///
  /// Example: Super Admin sets Admin A's permissions to only ['manage_offers']
  /// and Admin B's permissions to only ['manage_users'].
  Future<void> updateAdminPermissions(
    String adminUid,
    List<String> permissions,
  ) async {
    // Validate that all permissions are known
    final validPermissions = permissions
        .where((p) => AppConstants.allPermissions.contains(p))
        .toList();

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(adminUid)
        .update({'permissions_list': validPermissions});
  }

  /// Fetches all users with role 'admin' (for Super Admin panel).
  Future<List<UserModel>> fetchAdminUsers() async {
    final snap = await _firestore
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: AppConstants.roleAdmin)
        .get();
    return snap.docs.map((d) => UserModel.fromFirestore(d)).toList();
  }

  /// Revokes admin role → demotes to customer.
  Future<void> revokeAdmin(String adminUid) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(adminUid)
        .update({
          'role': AppConstants.roleCustomer,
          'permissions_list': [], // Clear all permissions on demotion
        });
  }

  /// Promotes a customer to admin with specified permissions.
  Future<void> promoteToAdmin(
    String uid,
    List<String> permissions,
  ) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({
          'role': AppConstants.roleAdmin,
          'permissions_list': permissions,
        });
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => 'AuthException: $message';
}
