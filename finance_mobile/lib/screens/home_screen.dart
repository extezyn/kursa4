import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_list.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/budget_widget.dart';
import 'add_expense_screen.dart';
import 'add_loan_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _exportTransactions(BuildContext context, List<dynamic> expenses) {
    final now = DateTime.now();
    String csv = 'Дата,Категория,Сумма\n';
    
    for (var expense in expenses) {
      csv += '${_dateFormat.format(expense.date)},${expense.category},${expense.amount}\n';
    }

    Share.share(csv, subject: 'Экспорт транзакций ${_dateFormat.format(now)}');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Финансовый учёт'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pie_chart), text: 'Обзор'),
            Tab(icon: Icon(Icons.list), text: 'Транзакции'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Бюджет'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _exportTransactions(context, provider.expenses),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Вкладка обзора
          Column(
            children: [
              Expanded(child: PieChartWidget(expenses: provider.expenses)),
              const SizedBox(height: 16),
            ],
          ),
          // Вкладка транзакций
          ExpenseList(expenses: provider.expenses),
          // Вкладка бюджета
          BudgetWidget(expenses: provider.expenses),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
