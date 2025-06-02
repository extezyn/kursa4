import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/filter_sheet.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  void _showAddExpenseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AddExpenseSheet(),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ExpenseProvider expenseProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: FilterSheet(
            onApplyFilters: (startDate, endDate, category) {
              expenseProvider.setFilters(startDate, endDate, category);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(ExpenseProvider expenseProvider) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final List<Widget> chips = [];

    // Добавляем чип с датами, если установлен фильтр по датам
    if (expenseProvider.startDate != null || expenseProvider.endDate != null) {
      final dateText = expenseProvider.startDate != null && expenseProvider.endDate != null
          ? '${dateFormat.format(expenseProvider.startDate!)} - ${dateFormat.format(expenseProvider.endDate!)}'
          : expenseProvider.startDate != null
              ? 'С ${dateFormat.format(expenseProvider.startDate!)}'
              : 'До ${dateFormat.format(expenseProvider.endDate!)}';

      chips.add(
        Chip(
          label: Text(dateText),
          onDeleted: () => expenseProvider.setFilters(null, null, expenseProvider.selectedCategory),
        ),
      );
    }

    // Добавляем чип с категорией, если установлен фильтр по категории
    if (expenseProvider.selectedCategory != null) {
      final categoryName = expenseProvider.categoryProvider.getCategoryById(expenseProvider.selectedCategory!)?.name ?? 'Категория';
      chips.add(
        Chip(
          label: Text(categoryName),
          onDeleted: () => expenseProvider.setFilters(expenseProvider.startDate, expenseProvider.endDate, null),
        ),
      );
    }

    return chips.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Транзакции'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
              _showFilterSheet(context, expenseProvider);
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          final expenses = expenseProvider.expenses;
          
          return Column(
            children: [
              _buildFilterChips(expenseProvider),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => expenseProvider.loadExpenses(),
                  child: expenses.isEmpty
                      ? const Center(
                          child: Text('Нет транзакций'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return ExpenseListItem(expense: expense);
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
} 