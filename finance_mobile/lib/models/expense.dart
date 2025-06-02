class Expense {
  final String id;
  final double amount;
  final DateTime date;
  final String category;
  final bool isIncome;
  final String? note;

  Expense({
    required this.id,
    required this.amount,
    required this.date,
    required this.category,
    required this.isIncome,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'isIncome': isIncome ? 1 : 0,
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      amount: map['amount'] as double,
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String,
      isIncome: (map['isIncome'] as int) == 1,
      note: map['note'] as String?,
    );
  }

  Expense copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? category,
    bool? isIncome,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      isIncome: isIncome ?? this.isIncome,
      note: note ?? this.note,
    );
  }
}
