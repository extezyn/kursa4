import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import '../../data/local/database.dart';
import '../../data/providers/budgets_provider.dart';
import '../../data/providers/categories_provider.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Бюджеты'),
      ),
      body: budgets.when(
        data: (data) => data.isEmpty
            ? const Center(
                child: Text(
                  'Нет активных бюджетов\nНажмите + чтобы добавить',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final budget = data[index];
                  return BudgetCard(budget: budget);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddBudgetSheet(),
    );
  }
}

class BudgetCard extends ConsumerWidget {
  final Budget budget;

  const BudgetCard({Key? key, required this.budget}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoriesProvider).when(
          data: (categories) =>
              categories.firstWhere((c) => c.id == budget.categoryId),
          loading: () => null,
          error: (_, __) => null,
        );

    if (category == null) return const SizedBox();

    final overrun = ref.watch(budgetOverrunProvider(budget.categoryId));
    final numberFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽');
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${category.icon} ${category.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteBudget(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Лимит: ${numberFormat.format(budget.amount)}'),
            Text(
              'Период: ${dateFormat.format(budget.startDate)} - ${dateFormat.format(budget.endDate)}',
            ),
            const SizedBox(height: 8),
            overrun.when(
              data: (data) {
                final percentage = data['percentage'] as double;
                final amount = data['amount'] as double;
                final isOverrun = data['isOverrun'] as bool;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(
                          percentage >= 100 ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Потрачено: ${numberFormat.format(amount)} (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: isOverrun ? Colors.red : null,
                        fontWeight: isOverrun ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Ошибка загрузки данных'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBudget(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить бюджет?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              ref.read(budgetRepositoryProvider).deleteBudget(budget.id);
              Navigator.of(context).pop();
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

class AddBudgetSheet extends ConsumerStatefulWidget {
  const AddBudgetSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends ConsumerState<AddBudgetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int? _selectedCategoryId;
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Новый бюджет',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            categories.when(
              data: (cats) {
                final expenseCategories =
                    cats.where((c) => !c.isIncome).toList();
                return DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    border: OutlineInputBorder(),
                  ),
                  items: expenseCategories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text('${category.icon} ${category.name}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Выберите категорию';
                    }
                    return null;
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Ошибка загрузки категорий'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Лимит',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите сумму';
                }
                if (double.tryParse(value) == null) {
                  return 'Введите корректное число';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _selectDateRange,
              child: Text(
                _dateRange == null
                    ? 'Выберите период'
                    : 'Период: ${DateFormat('dd.MM.yyyy').format(_dateRange!.start)} - ${DateFormat('dd.MM.yyyy').format(_dateRange!.end)}',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveBudget,
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _saveBudget() async {
    if (!_formKey.currentState!.validate() || _dateRange == null) {
      if (_dateRange == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выберите период')),
        );
      }
      return;
    }

    final budget = BudgetsCompanion(
      categoryId: Value(_selectedCategoryId!),
      amount: Value(double.parse(_amountController.text)),
      startDate: Value(_dateRange!.start),
      endDate: Value(_dateRange!.end),
    );

    try {
      await ref.read(budgetRepositoryProvider).addBudget(budget);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }
} 