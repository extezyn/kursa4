import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import 'dart:math' as math;

class PieChartWidget extends StatelessWidget {
  final List<Expense> expenses;
  const PieChartWidget({super.key, required this.expenses});

  Map<String, double> _calculateCategoryTotals() {
    final Map<String, double> totals = {};
    for (var expense in expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<Color> _generateColors(int count) {
    final List<Color> colors = [];
    for (var i = 0; i < count; i++) {
      colors.add(Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0));
    }
    return colors;
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text('Нет данных для отображения'));
    }

    final categoryTotals = _calculateCategoryTotals();
    final colors = _generateColors(categoryTotals.length);
    final total = categoryTotals.values.reduce((a, b) => a + b);

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: categoryTotals.entries.map((entry) {
                final index = categoryTotals.keys.toList().indexOf(entry.key);
                return PieChartSectionData(
                  color: colors[index],
                  value: entry.value,
                  title: '${(entry.value / total * 100).toStringAsFixed(1)}%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: categoryTotals.entries.map((entry) {
            final index = categoryTotals.keys.toList().indexOf(entry.key);
            return Chip(
              backgroundColor: colors[index].withOpacity(0.2),
              label: Text(
                '${entry.key}: ${entry.value.toStringAsFixed(2)} ₽',
                style: TextStyle(color: colors[index]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          'Всего: ${total.toStringAsFixed(2)} ₽',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}
