import 'package:flutter/foundation.dart';

@immutable
class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;

  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
  });
}
