import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import 'package:intl/intl.dart';

class FilterSheet extends StatefulWidget {
  final Function(DateTime?, DateTime?, String?) onApplyFilters;

  const FilterSheet({
    Key? key,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;
  String _selectedPeriod = 'all';
  final _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _updateDatesByPeriod('all');
  }

  void _updateDatesByPeriod(String period) {
    final now = DateTime.now();
    setState(() {
      _selectedPeriod = period;
      switch (period) {
        case 'today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'week':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _endDate = now;
          break;
        case 'month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case 'year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = DateTime(now.year, 12, 31, 23, 59, 59);
          break;
        case 'custom':
          // Оставляем текущие даты
          break;
        case 'all':
        default:
          _startDate = null;
          _endDate = null;
          break;
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        }
        _selectedPeriod = 'custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final allCategories = [...categoryProvider.expenseCategories, ...categoryProvider.incomeCategories];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Фильтры',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Период',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Все'),
                selected: _selectedPeriod == 'all',
                onSelected: (selected) => _updateDatesByPeriod('all'),
              ),
              ChoiceChip(
                label: const Text('Сегодня'),
                selected: _selectedPeriod == 'today',
                onSelected: (selected) => _updateDatesByPeriod('today'),
              ),
              ChoiceChip(
                label: const Text('Неделя'),
                selected: _selectedPeriod == 'week',
                onSelected: (selected) => _updateDatesByPeriod('week'),
              ),
              ChoiceChip(
                label: const Text('Месяц'),
                selected: _selectedPeriod == 'month',
                onSelected: (selected) => _updateDatesByPeriod('month'),
              ),
              ChoiceChip(
                label: const Text('Год'),
                selected: _selectedPeriod == 'year',
                onSelected: (selected) => _updateDatesByPeriod('year'),
              ),
              ChoiceChip(
                label: const Text('Свой период'),
                selected: _selectedPeriod == 'custom',
                onSelected: (selected) => _updateDatesByPeriod('custom'),
              ),
            ],
          ),
          if (_selectedPeriod == 'custom') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(_startDate == null 
                      ? 'Начальная дата'
                      : _dateFormat.format(_startDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(_endDate == null 
                      ? 'Конечная дата'
                      : _dateFormat.format(_endDate!),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Категория',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              hintText: 'Выберите категорию',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Все категории'),
              ),
              ...allCategories.map((category) => DropdownMenuItem<String>(
                value: category.id,
                child: Text(category.name),
              )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                    _selectedCategory = null;
                    _selectedPeriod = 'all';
                  });
                },
                child: const Text('Сбросить'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(_startDate, _endDate, _selectedCategory);
                  Navigator.pop(context);
                },
                child: const Text('Применить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 