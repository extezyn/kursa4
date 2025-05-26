import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_filter.dart';
import '../../data/providers/categories_provider.dart';
import '../../data/providers/transactions_provider.dart';

class FilterTransactionsPage extends ConsumerStatefulWidget {
  const FilterTransactionsPage({super.key});

  @override
  ConsumerState<FilterTransactionsPage> createState() => _FilterTransactionsPageState();
}

class _FilterTransactionsPageState extends ConsumerState<FilterTransactionsPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool? _isIncome;
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(transactionFilterProvider);
    _startDate = currentFilter?.startDate;
    _endDate = currentFilter?.endDate;
    _isIncome = currentFilter?.isIncome;
    _categoryId = currentFilter?.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильтр транзакций'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearFilter,
          ),
        ],
      ),
      body: categories.when(
        data: (categories) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Фильтр по типу (доход/расход)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Тип транзакции'),
                    const SizedBox(height: 8),
                    SegmentedButton<bool?>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Расход'),
                          icon: Icon(Icons.remove),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Доход'),
                          icon: Icon(Icons.add),
                        ),
                        ButtonSegment(
                          value: null,
                          label: Text('Все'),
                          icon: Icon(Icons.all_inclusive),
                        ),
                      ],
                      selected: {_isIncome},
                      onSelectionChanged: (Set<bool?> selected) {
                        setState(() {
                          _isIncome = selected.first;
                          _categoryId = null; // Сбрасываем категорию при смене типа
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Фильтр по категории
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Категория'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      value: _categoryId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Все категории'),
                        ),
                        ...categories
                            .where((c) => _isIncome == null || c.isIncome == _isIncome)
                            .map((category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text('${category.icon} ${category.name}'),
                                ))
                            .toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _categoryId = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Фильтр по дате
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Период'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(_startDate == null
                                ? 'Начало'
                                : '${_startDate!.day}.${_startDate!.month}.${_startDate!.year}'),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _startDate = date;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(_endDate == null
                                ? 'Конец'
                                : '${_endDate!.day}.${_endDate!.month}.${_endDate!.year}'),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _endDate = date;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _applyFilter,
          child: const Text('Применить фильтр'),
        ),
      ),
    );
  }

  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _isIncome = null;
      _categoryId = null;
    });
    ref.read(transactionFilterProvider.notifier).state = null;
    Navigator.of(context).pop();
  }

  void _applyFilter() {
    ref.read(transactionFilterProvider.notifier).state = TransactionFilter(
      startDate: _startDate,
      endDate: _endDate,
      isIncome: _isIncome,
      categoryId: _categoryId,
    );
    Navigator.of(context).pop();
  }
} 