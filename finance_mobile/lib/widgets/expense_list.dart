import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'package:intl/intl.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  const ExpenseList({super.key, required this.expenses});

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение'),
        content: const Text('Вы уверены, что хотите удалить эту транзакцию?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _deleteExpense(BuildContext context, String id) {
    Provider.of<ExpenseProvider>(context, listen: false).deleteExpense(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Транзакция удалена'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Dismissible(
          key: Key(expense.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) => _deleteExpense(context, expense.id),
          confirmDismiss: (direction) => _confirmDelete(context),
          child: ListTile(
            title: Text('${expense.category}: ${expense.amount.toStringAsFixed(2)} ₽'),
            subtitle: Text(dateFormat.format(expense.date)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (await _confirmDelete(context) == true) {
                  _deleteExpense(context, expense.id);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
