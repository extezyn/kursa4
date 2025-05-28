import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  
  const EditExpenseScreen({
    super.key,
    required this.expense,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController _amountController;
  late String _category;
  late bool _isIncome;
  String? _errorMessage;

  final Map<String, List<String>> _categories = {
    'Расходы': [
      'Продукты',
      'Кафе и рестораны',
      'Транспорт',
      'Развлечения',
      'Здоровье',
      'Одежда',
      'Дом',
      'Связь и интернет',
      'Образование',
      'Хобби',
      'Путешествия',
      'Подарки',
      'Прочее',
    ],
    'Доходы': [
      'Зарплата',
      'Фриланс',
      'Инвестиции',
      'Подарки',
      'Возврат долга',
      'Прочее',
    ],
  };

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

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense.amount.toString(),
    );
    _category = widget.expense.category;
    _isIncome = widget.expense.isIncome;
  }

  void _updateExpense() {
    try {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        setState(() {
          _errorMessage = 'Введите корректную сумму';
        });
        return;
      }

      final updatedExpense = Expense(
        id: widget.expense.id,
        category: _category,
        amount: amount,
        date: widget.expense.date,
        isIncome: _isIncome,
      );

      Provider.of<ExpenseProvider>(context, listen: false)
          .updateExpense(updatedExpense);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка ввода: введите числовое значение';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isIncome ? 'Редактировать доход' : 'Редактировать расход'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Text(
                        _getCategoryIcon(_category),
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Расход'),
                        icon: Icon(Icons.remove_circle_outline),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Доход'),
                        icon: Icon(Icons.add_circle_outline),
                      ),
                    ],
                    selected: {_isIncome},
                    onSelectionChanged: (Set<bool> selected) {
                      setState(() {
                        _isIncome = selected.first;
                        _category = _categories[_isIncome ? 'Доходы' : 'Расходы']!.first;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Сумма',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              prefixIcon: const Icon(Icons.currency_ruble),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorText: _errorMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Категория',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories[_isIncome ? 'Доходы' : 'Расходы']!
                                .map((category) {
                              final isSelected = category == _category;
                              return FilterChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_getCategoryIcon(category)),
                                    const SizedBox(width: 8),
                                    Text(category),
                                  ],
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _category = category;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _updateExpense,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Сохранить изменения'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
} 