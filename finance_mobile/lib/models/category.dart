class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final bool isIncome;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'isIncome': isIncome ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      isIncome: (map['isIncome'] as int?) == 1,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    bool? isIncome,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isIncome: isIncome ?? this.isIncome,
    );
  }
} 