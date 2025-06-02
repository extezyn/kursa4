import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:uuid/uuid.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';

class ReminderProvider with ChangeNotifier {
  static const platform = MethodChannel('com.example.finance_mobile/notifications');
  List<Reminder> _reminders = [];
  final _uuid = const Uuid();
  bool _isInitialized = false;

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  ReminderProvider() {
    _initializeNotifications();
    loadReminders();
  }

  Future<void> _initializeNotifications() async {
    if (_isInitialized) return;
    tz.initializeTimeZones();
    _isInitialized = true;
  }

  Future<void> loadReminders() async {
    _reminders = await DatabaseService.getReminders();
    notifyListeners();
  }

  Future<void> addReminder(String title, String message, DateTime dateTime) async {
    final reminder = Reminder(
      id: _uuid.v4(),
      title: title,
      message: message,
      dateTime: dateTime,
    );

    await DatabaseService.insertReminder(reminder);
    await _scheduleNotification(reminder);
    await loadReminders();
  }

  Future<void> updateReminder(Reminder reminder) async {
    await DatabaseService.updateReminder(reminder);
    await _cancelNotification(reminder.id);
    if (reminder.isActive) {
      await _scheduleNotification(reminder);
    }
    await loadReminders();
  }

  Future<void> deleteReminder(String id) async {
    await DatabaseService.deleteReminder(id);
    await _cancelNotification(id);
    await loadReminders();
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    if (!reminder.isActive) return;

    try {
      await platform.invokeMethod('scheduleNotification', {
        'title': reminder.title,
        'message': reminder.message,
        'timestamp': reminder.dateTime.millisecondsSinceEpoch,
        'id': reminder.id.hashCode,
      });
    } catch (e) {
      debugPrint('Ошибка при планировании уведомления: $e');
    }
  }

  Future<void> _cancelNotification(String id) async {
    try {
      await platform.invokeMethod('cancelNotification', {
        'id': id.hashCode,
      });
    } catch (e) {
      debugPrint('Ошибка при отмене уведомления: $e');
    }
  }
} 