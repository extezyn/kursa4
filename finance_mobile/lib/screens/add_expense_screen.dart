import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../models/expense.dart';
import '../models/category.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  bool _isIncome = false;
  String? _errorMessage;

  void _saveExpense() {
    try {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        setState(() {
          _errorMessage = 'Введите корректную сумму';
        });
        return;
      }
      
      if (amount > 999999999) {
        setState(() {
          _errorMessage = 'Сумма не может превышать 999,999,999';
        });
        return;
      }

      if (_selectedCategoryId == null) {
        setState(() {
          _errorMessage = 'Выберите категорию';
        });
        return;
      }

      final expense = Expense(
        id: const Uuid().v4(),
        category: _selectedCategoryId!,
        amount: amount,
        date: DateTime.now(),
        isIncome: _isIncome,
      );

      Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка при сохранении: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isIncome ? 'Добавить доход' : 'Добавить расход'),
        elevation: 0,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          final categories = _isIncome 
            ? categoryProvider.incomeCategories 
            : categoryProvider.expenseCategories;

          if (_selectedCategoryId == null && categories.isNotEmpty) {
            _selectedCategoryId = categories.first.id;
          }

          return SingleChildScrollView(
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
                          child: Icon(
                            _selectedCategoryId != null
                                ? categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'shopping_cart'
                                    ? Icons.shopping_cart
                                    : categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'restaurant'
                                    ? Icons.restaurant
                                    : categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'directions_car'
                                    ? Icons.directions_car
                                    : categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'movie'
                                    ? Icons.movie
                                    : categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'local_hospital'
                                    ? Icons.local_hospital
                                    : categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'home'
                                    ? Icons.home
                                    : categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'checkroom'
                                    ? Icons.checkroom
                                    : categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'phone_android'
                                    ? Icons.phone_android
                                    : categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'school'
                                    ? Icons.school
                                    : categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'card_giftcard'
                                    ? Icons.card_giftcard
                                    : categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'account_balance_wallet'
                                    ? Icons.account_balance_wallet
                                    : categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'computer'
                                    ? Icons.computer
                                    : categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'redeem'
                                    ? Icons.redeem
                                    : categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'trending_up'
                                    ? Icons.trending_up
                                    : categoryProvider.getCategoryById(_selectedCategoryId!)?.icon == 'business_center'
                                    ? Icons.business_center
                                    : Icons.category
                                : Icons.category,
                            size: 40,
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
                            _selectedCategoryId = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Сумма',
                          errorText: _errorMessage,
                          prefixIcon: const Icon(Icons.money),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Категория',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveExpense,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Сохранить'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
