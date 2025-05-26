import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> showBudgetOverrunNotification({
    required String categoryName,
    required double amount,
    required double limit,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'budget_alerts',
      'Превышение бюджета',
      channelDescription: 'Уведомления о превышении бюджета',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final percentage = ((amount / limit) * 100).toStringAsFixed(1);

    await _notifications.show(
      0,
      'Превышение бюджета',
      'Расходы в категории "$categoryName" превысили установленный лимит на $percentage%',
      details,
    );
  }
} 