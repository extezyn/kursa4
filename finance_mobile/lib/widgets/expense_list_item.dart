import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/category_provider.dart';
import 'package:provider/provider.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;

  const ExpenseListItem({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final category = categoryProvider.getCategoryName(expense.category);
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          expense.note?.isNotEmpty == true
              ? expense.note!
              : category,
        ),
        subtitle: Text(
          '${dateFormat.format(expense.date)} • $category',
        ),
        trailing: Text(
          '${expense.amount.toStringAsFixed(2)} ₽',
          style: TextStyle(
            color: expense.isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 