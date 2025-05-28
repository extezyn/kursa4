import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../screens/edit_expense_screen.dart';
import 'package:intl/intl.dart';

class ExpenseList extends StatefulWidget {
  final List<Expense> expenses;
  const ExpenseList({super.key, required this.expenses});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  String _sortOrder = 'desc'; // 'asc' или 'desc'
  String _filter = 'all'; // 'all', 'income' или 'expense'

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

  void _editExpense(BuildContext context, Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(expense: expense),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'продукты':
        return '🛒';
      case 'кафе и рестораны':
        return '🍽️';
      case 'транспорт':
        return '🚗';
      case 'развлечения':
        return '🎮';
      case 'здоровье':
        return '🏥';
      case 'одежда':
        return '👕';
      case 'дом':
        return '🏠';
      case 'связь и интернет':
        return '📱';
      case 'образование':
        return '📚';
      case 'хобби':
        return '🎨';
      case 'путешествия':
        return '✈️';
      case 'подарки':
        return '🎁';
      case 'зарплата':
        return '💰';
      case 'фриланс':
        return '💻';
      case 'инвестиции':
        return '📈';
      case 'возврат долга':
        return '🔄';
      default:
        return '📝';
    }
  }

  List<Expense> _getFilteredAndSortedExpenses() {
    List<Expense> filteredExpenses = List.from(widget.expenses);

    // Применяем фильтр
    if (_filter != 'all') {
      filteredExpenses = filteredExpenses.where((e) => 
        _filter == 'income' ? e.isIncome : !e.isIncome
      ).toList();
    }

    // Сортируем
    filteredExpenses.sort((a, b) {
      int dateComparison = b.date.compareTo(a.date);
      return _sortOrder == 'desc' ? dateComparison : -dateComparison;
    });

    return filteredExpenses;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final filteredExpenses = _getFilteredAndSortedExpenses();
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'all',
                      label: Text('Все'),
                    ),
                    ButtonSegment<String>(
                      value: 'income',
                      label: Text('Доходы'),
                    ),
                    ButtonSegment<String>(
                      value: 'expense',
                      label: Text('Расходы'),
                    ),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (Set<String> selected) {
                    setState(() {
                      _filter = selected.first;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(_sortOrder == 'desc' 
                  ? Icons.arrow_downward 
                  : Icons.arrow_upward
                ),
                onPressed: () {
                  setState(() {
                    _sortOrder = _sortOrder == 'desc' ? 'asc' : 'desc';
                  });
                },
                tooltip: _sortOrder == 'desc' 
                  ? 'Сначала новые' 
                  : 'Сначала старые',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredExpenses.length,
            itemBuilder: (context, index) {
              final expense = filteredExpenses[index];
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
                child: InkWell(
                  onLongPress: () => _editExpense(context, expense),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                _getCategoryIcon(expense.category),
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expense.category,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateFormat.format(expense.date),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${expense.isIncome ? '+' : '-'}${expense.amount.toStringAsFixed(2)} ₽',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: expense.isIncome 
                                ? Colors.green 
                                : Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
