import 'package:flutter/material.dart';
import 'transactions_page.dart';
import 'analytics_page.dart';
import 'budgets_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const _pages = [
    TransactionsPage(),
    AnalyticsPage(),
    BudgetsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            label: 'Транзакции',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Аналитика',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Бюджеты',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
} 