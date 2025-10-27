import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/task.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _notificationsEnabled = false;

  Future<void> initialize({required bool notificationsEnabled}) async {
    if (!_initialized) {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();

      await _localNotificationsPlugin.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification payload: ${response.payload}');
        },
      );

      await _configureLocalTimezone();
      await _configureFirebaseMessaging();
      _initialized = true;
    }

    if (notificationsEnabled && !_notificationsEnabled) {
      await _requestPermissions();
    }

    _notificationsEnabled = notificationsEnabled;
  }

  Future<void> _configureFirebaseMessaging() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    final messaging = FirebaseMessaging.instance;
    await messaging.setAutoInitEnabled(true);
    final token = await messaging.getToken();
    debugPrint('FCM токен: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _showInstantNotification(
          title: notification.title ?? 'Планировщик',
          body: notification.body ?? 'Новое уведомление',
        );
      }
    });
  }

  Future<void> _requestPermissions() async {
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await FirebaseMessaging.instance.requestPermission();
  }

  Future<void> _configureLocalTimezone() async {
    tz.initializeTimeZones();
    try {
      final timezoneName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (error) {
      debugPrint('Не удалось получить часовую зону: $error');
      tz.setLocalLocation(tz.getLocation('Etc/UTC'));
    }
  }

  Future<void> scheduleTaskReminder(Task task) async {
    if (!_initialized || !_notificationsEnabled) return;
    final scheduledDate = task.startTime
        .subtract(Duration(minutes: task.reminderMinutesBefore));
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'tasks_channel',
      'Напоминания о задачах',
      channelDescription: 'Локальные уведомления для задач и событий',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotificationsPlugin.zonedSchedule(
      task.id.hashCode,
      task.title,
      task.description ?? 'Напоминание о задаче',
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id,
    );
  }

  Future<void> cancelReminder(String taskId) async {
    if (!_initialized) return;
    await _localNotificationsPlugin.cancel(taskId.hashCode);
  }

  Future<void> _showInstantNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Уведомления',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    await _localNotificationsPlugin.show(
      title.hashCode,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
