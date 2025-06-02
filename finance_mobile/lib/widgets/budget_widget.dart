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
    _budgetController.text = _monthlyBudget.toString();
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
      _budgetController.text = _monthlyBudget.toString();
    });
  }

  Future<void> _saveBudget(double budget) async {
    if (budget < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Бюджет не может быть отрицательным'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
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
    final monthlyExpenses = widget.expenses
        .where((expense) =>
            !expense.isIncome &&
            expense.date.year == now.year && 
            expense.date.month == now.month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
    return monthlyExpenses;
  }

  double _calculateMonthlyIncome() {
    final now = DateTime.now();
    return widget.expenses
        .where((expense) =>
            expense.isIncome &&
            expense.date.year == now.year && 
            expense.date.month == now.month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    final monthlyExpenses = _calculateMonthlyExpenses();
    final monthlyIncome = _calculateMonthlyIncome();
    final remaining = _monthlyBudget - monthlyExpenses;
    final progress = _monthlyBudget > 0 ? monthlyExpenses / _monthlyBudget : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Месячный бюджет',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Switch(
                        value: _isBudgetEnabled,
                        onChanged: _toggleBudget,
                      ),
                    ],
                  ),
                  if (_isBudgetEnabled) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _budgetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Установить бюджет',
                        prefixIcon: Icon(Icons.currency_ruble),
                        border: OutlineInputBorder(),
                        hintText: 'Введите сумму бюджета',
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          _saveBudget(0);
                          return;
                        }
                        final budget = double.tryParse(value);
                        if (budget != null) {
                          _saveBudget(budget);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Потрачено: ${monthlyExpenses.toStringAsFixed(2)} ₽',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'Осталось: ${remaining.toStringAsFixed(2)} ₽',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: remaining < 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Статистика за месяц',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Доходы:',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            '${monthlyIncome.toStringAsFixed(2)} ₽',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Расходы:',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            '${monthlyExpenses.toStringAsFixed(2)} ₽',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.red,
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
        ],
      ),
    );
  }
} 