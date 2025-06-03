import 'package:flutter/foundation.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';

class ReminderProvider with ChangeNotifier {
  List<Reminder> _reminders = [];

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  Future<void> loadReminders() async {
    _reminders = await DatabaseService.getReminders();
    notifyListeners();
  }

  Future<void> addReminder(Reminder reminder) async {
    await DatabaseService.insertReminder(reminder);
    await loadReminders();
  }

  Future<void> updateReminder(Reminder reminder) async {
    await DatabaseService.updateReminder(reminder);
    await loadReminders();
  }

  Future<void> deleteReminder(String id) async {
    await DatabaseService.deleteReminder(id);
    await loadReminders();
  }
} 