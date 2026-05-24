// lib/data/datasources/remote/notification_service.dart
// FCM push notifications + local notifications

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';

// Top-level handler (required by FCM for background messages)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
}

class NotificationService {
  final FirebaseMessaging        _messaging;
  final FirebaseFirestore         _firestore;
  final FlutterLocalNotificationsPlugin _localNotifications;

  NotificationService({
    required FirebaseMessaging messaging,
    required FirebaseFirestore firestore,
    required FlutterLocalNotificationsPlugin localNotifications,
  })  : _messaging          = messaging,
        _firestore          = firestore,
        _localNotifications = localNotifications;

  // ─── Initialize ──────────────────────────────────────────────────────────────
  Future<void> initialize(String userId) async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );

    // Android notification channel
    const channel = AndroidNotificationChannel(
      'dava_high_importance',
      'DAVA Store Notifications',
      description: 'Order updates, deals, and announcements',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Init local notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS:     DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initSettings);

    // Get FCM token and save to Firestore
    final token = await _messaging.getToken();
    if (token != null) await _saveFcmToken(userId, token);

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _saveFcmToken(userId, newToken);
    });

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // ─── Foreground Handler ───────────────────────────────────────────────────────
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'dava_high_importance',
          'DAVA Store Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(presentAlert: true),
      ),
    );
  }

  // ─── Save FCM Token ───────────────────────────────────────────────────────────
  Future<void> _saveFcmToken(String userId, String token) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'fcm_token': token, 'fcm_updated_at': FieldValue.serverTimestamp()});
  }

  // ─── Send Notification (Admin use) ───────────────────────────────────────────
  /// Saves a notification document to Firestore.
  /// A Cloud Function (or admin SDK) would then fan out FCM messages.
  Future<void> sendBroadcastNotification({
    required String title,
    required String body,
    String? targetUserId, // null = broadcast to all
    Map<String, String>? data,
  }) async {
    await _firestore
        .collection(AppConstants.notificationsCollection)
        .add({
          'title':          title,
          'body':           body,
          'target_user_id': targetUserId,
          'data':           data ?? {},
          'sent_at':        FieldValue.serverTimestamp(),
          'is_broadcast':   targetUserId == null,
        });
  }

  // ─── Get User Notifications ───────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('target_user_id', isEqualTo: userId)
        .orderBy('sent_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList());
  }
}
