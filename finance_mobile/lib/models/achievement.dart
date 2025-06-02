class Achievement {
  String id;
  String name;
  String description;
  String icon;
  bool isUnlocked;
  double progress;
  double targetValue;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.progress = 0.0,
    required this.targetValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'progress': progress,
      'targetValue': targetValue,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      isUnlocked: json['isUnlocked'],
      progress: json['progress'],
      targetValue: json['targetValue'],
    );
  }
} 