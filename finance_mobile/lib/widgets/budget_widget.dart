import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class BudgetWidget extends StatefulWidget {
  const BudgetWidget({Key? key}) : super(key: key);

  @override
  State<BudgetWidget> createState() => _BudgetWidgetState();
}

class _BudgetWidgetState extends State<BudgetWidget> {
  double _budget = 0;
  double _spent = 0;
  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBudget();
    _calculateSpent();
  }

  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _budget = prefs.getDouble('monthly_budget') ?? 0;
    });
  }

  Future<void> _saveBudget(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_budget', value);
    setState(() {
      _budget = value;
    });
  }

  void _calculateSpent() {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthlyExpenses = expenseProvider.expenses.where((expense) =>
        !expense.isIncome &&
        expense.date.isAfter(startOfMonth) &&
        expense.date.isBefore(endOfMonth));

    setState(() {
      _spent = monthlyExpenses.fold(0, (sum, expense) => sum + expense.amount);
    });
  }

  void _showBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Установить бюджет'),
        content: TextField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Месячный бюджет',
            prefixIcon: Icon(Icons.money),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(_budgetController.text);
              if (value != null && value > 0) {
                _saveBudget(value);
              }
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _budget - _spent;
    final progress = _budget > 0 ? (_spent / _budget).clamp(0.0, 1.0) : 0.0;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Месячный бюджет',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _showBudgetDialog,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.9 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Потрачено: ${_spent.toStringAsFixed(2)}'),
                Text(
                  'Осталось: ${remaining.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: remaining < 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }
} 