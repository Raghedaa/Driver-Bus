import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/providers/auth_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../firebase_options.dart';
import '../../modules/home/schedule/controllers/schedule_controller.dart';
import '../../modules/notifications/controller/notifications_controller.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
  );

  Future<NotificationService> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await Permission.notification.request();

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    await _initLocalNotifications();
    await _configureAndroidHeadsUpNotifications();

    _configureForegroundListening();
    _configureNotificationClick();
    _handleInitialMessage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      syncTokenToServer();
    });

    return this;
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _navigateToNotificationsScreen();
      },
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _configureAndroidHeadsUpNotifications() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _configureForegroundListening() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received foreground message: ${message.messageId}");

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        _localNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              playSound: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      }

      if (Get.isRegistered<NotificationsController>()) {
        final controller = Get.find<NotificationsController>();
        controller.loadNotifications();
      }

      if (Get.isRegistered<ScheduleController>()) {
        final scheduleController = Get.find<ScheduleController>();
        scheduleController.fetchTrips();
      }
    });
  }

  void _configureNotificationClick() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked from background: ${message.messageId}");
      _navigateToNotificationsScreen();
    });
  }

  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print(
        "Notification clicked from terminated state: ${initialMessage.messageId}",
      );
      Future.delayed(const Duration(milliseconds: 600), () {
        _navigateToNotificationsScreen();
      });
    }
  }

  void _navigateToNotificationsScreen() {
    Get.toNamed('/notifications');
  }

  Future<void> syncTokenToServer() async {
    final storage = GetStorage();
    if (storage.read('token') == null) {
      print("FCM Token Sync Skipped: User is not logged in yet.");
      return;
    }

    String? token = await _messaging.getToken();
    print("Firebase Device Token: $token");

    if (token != null) {
      try {
        final authProvider = AuthProvider();
        final authRepository = AuthRepository(authProvider);
        String platform = GetPlatform.isAndroid ? "android" : "ios";

        final response = await authRepository.updateFcmToken(token, platform);
        if (response.statusCode == 200) {
          print("FCM Token Sync Success: ${response.data['message']}");
        }
      } catch (e) {
        print("Error syncing FCM Token to server: $e");
      }
    }
  }
}
