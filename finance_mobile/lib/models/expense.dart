class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final bool isIncome; // true - доход, false - расход

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'isIncome': isIncome ? 1 : 0,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      category: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      isIncome: map['isIncome'] == 1,
    );
  }
}
