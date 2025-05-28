import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetWidget extends StatefulWidget {
  final List<Expense> expenses;
  const BudgetWidget({super.key, required this.expenses});

  @override
  State<BudgetWidget> createState() => _BudgetWidgetState();
}

class _BudgetWidgetState extends State<BudgetWidget> {
  double _monthlyBudget = 0;
  bool _isBudgetEnabled = false;
  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBudgetSettings();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _loadBudgetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _monthlyBudget = prefs.getDouble('monthlyBudget') ?? 0;
      _isBudgetEnabled = prefs.getBool('isBudgetEnabled') ?? false;
    });
  }

  Future<void> _saveBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthlyBudget', budget);
    setState(() {
      _monthlyBudget = budget;
    });
  }

  Future<void> _toggleBudget(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBudgetEnabled', enabled);
    setState(() {
      _isBudgetEnabled = enabled;
    });
  }

  double _calculateMonthlyExpenses() {
    final now = DateTime.now();
    return widget.expenses
        .where((expense) =>
            expense.date.year == now.year && expense.date.month == now.month)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    final monthlyExpenses = _calculateMonthlyExpenses();
    final remaining = _monthlyBudget - monthlyExpenses;
    final progress = _monthlyBudget > 0 ? monthlyExpenses / _monthlyBudget : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            title: const Text('Включить бюджет'),
            value: _isBudgetEnabled,
            onChanged: _toggleBudget,
          ),
          if (_isBudgetEnabled) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Месячный бюджет',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_monthlyBudget.toStringAsFixed(2)} ₽',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1 ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Потрачено'),
                            Text(
                              '${monthlyExpenses.toStringAsFixed(2)} ₽',
                              style: TextStyle(
                                color: progress >= 1 ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Осталось'),
                            Text(
                              '${remaining.toStringAsFixed(2)} ₽',
                              style: TextStyle(
                                color: remaining < 0 ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _budgetController.text = _monthlyBudget.toString();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Установить бюджет'),
                    content: TextField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Месячный бюджет',
                        suffixText: '₽',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () {
                          final budget = double.tryParse(_budgetController.text) ?? 0;
                          _saveBudget(budget);
                          Navigator.pop(context);
                        },
                        child: const Text('Сохранить'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Установить бюджет'),
            ),
          ],
        ],
      ),
    );
  }
} 