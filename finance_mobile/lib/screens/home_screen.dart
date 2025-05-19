import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_list.dart';
import '../widgets/pie_chart_widget.dart';
import 'add_expense_screen.dart';
import 'add_loan_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Финансовый учёт'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AnalyticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.attach_money),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddLoanScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: PieChartWidget(expenses: provider.expenses)),
          const SizedBox(
            height: 16,
          ), // Добавляем SizedBox для вертикального отступа
          Expanded(child: ExpenseList(expenses: provider.expenses)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
