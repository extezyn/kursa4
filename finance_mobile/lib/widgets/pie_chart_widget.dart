import 'package:flutter/material.dart';
import '../models/expense.dart';

class PieChartWidget extends StatelessWidget {
  final List<Expense> expenses;
  const PieChartWidget({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    // Здесь предполагается реализация графика (например, с fl_chart)
    return SizedBox(
      height: 200, // Используем SizedBox вместо Container
      child: const Center(child: Text('Pie Chart Placeholder')),
    );
  }
}
