import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/overview_card.dart';
import '../widgets/category_pie_chart.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({Key? key}) : super(key: key);

  void _showFilterSheet(BuildContext context, ExpenseProvider expenseProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FilterSheet(
          onApplyFilters: (startDate, endDate, category) {
            expenseProvider.setFilters(startDate, endDate, category);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final balance = expenseProvider.balance;
    final income = expenseProvider.totalIncome;
    final expense = expenseProvider.totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Обзор'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, expenseProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => expenseProvider.loadExpenses(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OverviewCard(
              balance: balance,
              income: income,
              expense: expense,
            ),
            const SizedBox(height: 24),
            Text(
              'Расходы по категориям',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: CategoryPieChart(
                categoryTotals: expenseProvider.getCategoryTotals(onlyExpenses: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 