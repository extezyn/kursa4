class Reminder {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final bool isActive;

  Reminder({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'dateTime': dateTime.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      dateTime: DateTime.parse(map['dateTime']),
      isActive: map['isActive'] == 1,
    );
  }
} 