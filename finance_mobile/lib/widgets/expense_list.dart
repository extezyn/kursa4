import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'package:intl/intl.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  const ExpenseList({super.key, required this.expenses});

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
          onDismissed: (direction) {
            Provider.of<ExpenseProvider>(context, listen: false)
                .deleteExpense(expense.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Транзакция удалена'),
                action: SnackBarAction(
                  label: 'Ок',
                  onPressed: () {},
                ),
              ),
            );
          },
          confirmDismiss: (direction) async {
            return await showDialog(
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
          },
          child: ListTile(
            title: Text('${expense.category}: ${expense.amount.toStringAsFixed(2)} ₽'),
            subtitle: Text(dateFormat.format(expense.date)),
          ),
        );
      },
    );
  }
}
