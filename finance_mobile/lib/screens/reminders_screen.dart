import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Напоминания'),
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, provider, child) {
          final reminders = provider.reminders;
          if (reminders.isEmpty) {
            return const Center(
              child: Text('Нет напоминаний'),
            );
          }

          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return _buildReminderCard(context, reminder, provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    Reminder reminder,
    ReminderProvider provider,
  ) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(reminder.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reminder.message),
            Text(
              dateFormat.format(reminder.dateTime),
              style: TextStyle(
                color: reminder.dateTime.isBefore(DateTime.now())
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: reminder.isActive,
              onChanged: (value) {
                provider.updateReminder(
                  Reminder(
                    id: reminder.id,
                    title: reminder.title,
                    message: reminder.message,
                    dateTime: reminder.dateTime,
                    isActive: value,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditReminderDialog(context, reminder),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmationDialog(
                context,
                reminder,
                provider,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddReminderDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новое напоминание'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Заголовок',
                ),
              ),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Сообщение',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Дата'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    selectedDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      selectedDate.hour,
                      selectedDate.minute,
                    );
                  }
                },
              ),
              ListTile(
                title: const Text('Время'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    selectedTime = time;
                    selectedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      time.hour,
                      time.minute,
                    );
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                Provider.of<ReminderProvider>(context, listen: false).addReminder(
                  titleController.text,
                  messageController.text,
                  selectedDate,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditReminderDialog(
    BuildContext context,
    Reminder reminder,
  ) async {
    final titleController = TextEditingController(text: reminder.title);
    final messageController = TextEditingController(text: reminder.message);
    DateTime selectedDate = reminder.dateTime;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(reminder.dateTime);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать напоминание'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Заголовок',
                ),
              ),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Сообщение',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Дата'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    selectedDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      selectedDate.hour,
                      selectedDate.minute,
                    );
                  }
                },
              ),
              ListTile(
                title: const Text('Время'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    selectedTime = time;
                    selectedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      time.hour,
                      time.minute,
                    );
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                Provider.of<ReminderProvider>(context, listen: false)
                    .updateReminder(
                  Reminder(
                    id: reminder.id,
                    title: titleController.text,
                    message: messageController.text,
                    dateTime: selectedDate,
                    isActive: reminder.isActive,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    Reminder reminder,
    ReminderProvider provider,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить напоминание?'),
        content: Text('Вы уверены, что хотите удалить напоминание "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteReminder(reminder.id);
              Navigator.pop(context);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
} 