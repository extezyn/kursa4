import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../data/local/database.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/categories_provider.dart';

class AddEditTransactionPage extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionPage({super.key, this.transaction});

  @override
  ConsumerState<AddEditTransactionPage> createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends ConsumerState<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  Category? _selectedCategory;
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
    _selectedDate = widget.transaction?.date ?? DateTime.now();
    _isIncome = widget.transaction?.isIncome ?? false;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Новая транзакция' : 'Редактировать транзакцию'),
      ),
      body: categories.when(
        data: (categories) {
          if (_selectedCategory == null && categories.isNotEmpty) {
            _selectedCategory = categories.first;
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Сумма',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите сумму';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Пожалуйста, введите корректное число';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Category>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categories
                      .where((c) => c.isIncome == _isIncome)
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Пожалуйста, выберите категорию';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Дата'),
                  subtitle: Text(
                    '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Тип транзакции'),
                  subtitle: Text(_isIncome ? 'Доход' : 'Расход'),
                  value: _isIncome,
                  onChanged: (value) {
                    setState(() {
                      _isIncome = value;
                      _selectedCategory = null;
                    });
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveTransaction,
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text;

      if (widget.transaction == null) {
        // Создаем новую транзакцию
        ref.read(databaseProvider).into(ref.read(databaseProvider).transactions).insert(
              TransactionsCompanion.insert(
                amount: amount,
                categoryId: _selectedCategory!.id,
                description: Value(description.isNotEmpty ? description : null),
                date: _selectedDate,
                isIncome: _isIncome,
              ),
            );
      } else {
        // Обновляем существующую транзакцию
        ref.read(databaseProvider).update(ref.read(databaseProvider).transactions).replace(
              Transaction(
                id: widget.transaction!.id,
                amount: amount,
                categoryId: _selectedCategory!.id,
                description: description.isNotEmpty ? description : null,
                date: _selectedDate,
                isIncome: _isIncome,
              ),
            );
      }

      Navigator.of(context).pop();
    }
  }
} 