import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level background message handler required by FirebaseMessaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('🔔 [FCM Background Message]: ${message.messageId} - ${message.notification?.title}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const String channelId = 'rozgar_notifications_channel';
  static const String channelName = 'Rozgar Adda Notifications';
  static const String channelDescription =
      'Notifications for jobs, candidate applications and updates';

  FirebaseMessaging? _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _deviceToken;
  bool _isInitialized = false;
  bool _isFirebaseReady = false;

  String? get deviceToken => _deviceToken;
  bool get isFirebaseReady => _isFirebaseReady;

  /// Initializes both Firebase Messaging and Flutter Local Notifications.
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Initialize Local Notifications Plugin first (always available offline)
    await _initLocalNotifications();

    // 2. Initialize Firebase Messaging
    await _initFirebaseMessaging();
  }

  Future<void> _initLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('🔔 [Notification Tapped] payload: ${response.payload}');
        },
      );

      // Create Android High-Importance Channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      debugPrint('✅ [Local Notifications] Channel created successfully.');
    } catch (e) {
      debugPrint('⚠️ [Local Notifications] Init error: $e');
    }
  }

  Future<void> _initFirebaseMessaging() async {
    try {
      // Initialize Firebase App
      await Firebase.initializeApp();
      _isFirebaseReady = true;
      _firebaseMessaging = FirebaseMessaging.instance;
      final messaging = _firebaseMessaging!;

      // Request runtime notification permission (Android 13+ & iOS)
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('🔔 [FCM Permission] Authorization Status: ${settings.authorizationStatus}');

      // Set foreground notification presentation
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Retrieve FCM Device Token
      await fetchDeviceToken();

      // Listen for token refreshes
      messaging.onTokenRefresh.listen((newToken) async {
        _deviceToken = newToken;
        debugPrint('🔔 [FCM Token Refreshed]: $newToken');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_device_token', newToken);
      });

      // Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 [FCM Foreground] Title: ${message.notification?.title}, Body: ${message.notification?.body}');
        final notification = message.notification;
        if (notification != null) {
          showNotification(
            title: notification.title ?? 'Rozgar Adda',
            body: notification.body ?? '',
            payload: message.data.toString(),
          );
        }
      });

      // Handle App opened via notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🔔 [FCM onMessageOpenedApp] Notification opened app: ${message.data}');
      });

      // Handle Cold Start from Notification
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🔔 [FCM InitialMessage] Cold start: ${initialMessage.data}');
      }
    } catch (e) {
      _isFirebaseReady = false;
      debugPrint('⚠️ [FCM Init Error]: $e');
      debugPrint('ℹ️ Note: If Firebase credentials/google-services.json is not configured yet, push notifications will activate once added.');
    }
  }

  /// Retrieves the FCM Device Token, caches it, and prints it clearly.
  Future<String?> fetchDeviceToken() async {
    try {
      if (_firebaseMessaging == null) {
        await Firebase.initializeApp();
        _firebaseMessaging = FirebaseMessaging.instance;
        _isFirebaseReady = true;
      }
      final token = await _firebaseMessaging?.getToken();
      _deviceToken = token;

      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_device_token', token);

        debugPrint('╔════════════════════════════════════════════════════════════════════╗');
        debugPrint('║ 🔔 ROZGAR ADDA FCM DEVICE TOKEN:                                  ║');
        debugPrint('║ $token');
        debugPrint('╚════════════════════════════════════════════════════════════════════╝');
      }
      return token;
    } catch (e) {
      debugPrint('⚠️ [FCM Token Error]: $e');
      final prefs = await SharedPreferences.getInstance();
      _deviceToken = prefs.getString('fcm_device_token');
      return _deviceToken;
    }
  }

  /// Triggers a local heads-up notification instantly.
  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id: id == 0 ? DateTime.now().millisecondsSinceEpoch ~/ 1000 : id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
      debugPrint('✅ [Local Notification Sent]: $title - $body');
    } catch (e) {
      debugPrint('⚠️ [Show Notification Error]: $e');
    }
  }

  /// Triggers an immediate test notification for developer verification.
  Future<void> showTestNotification() async {
    await showNotification(
      title: '🎉 Rozgar Adda Notification',
      body: 'Your notification service is active and working properly!',
      payload: '{"type":"test","timestamp":"${DateTime.now().toIso8601String()}"}',
    );
  }

  /// Helper to copy the Device Token to clipboard and show feedback.
  Future<void> copyTokenToClipboard(BuildContext context) async {
    final token = _deviceToken ?? await fetchDeviceToken();
    if (token != null && token.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: token));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF801438),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Device token copied to clipboard!',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.grey.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: const Text(
              'Device token not ready yet. Please check Firebase setup.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        );
      }
    }
  }

  /// Displays a dialog with the Device Token and a button to send a test notification.
  Future<void> showDeviceTokenDialog(BuildContext context) async {
    final token = _deviceToken ?? await fetchDeviceToken();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF801438).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFF801438),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Push Notification Setup',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'FCM Device Token & Notification Test',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'DEVICE TOKEN (FCM):',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: SelectableText(
                token ?? 'Connecting to Firebase... Please ensure google-services.json is added.',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      copyTokenToClipboard(context);
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy Token'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF801438),
                      side: const BorderSide(color: Color(0xFF801438)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await showTestNotification();
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Test notification triggered!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Test Notification'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF801438),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
