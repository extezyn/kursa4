import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategoryPieChart({
    Key? key,
    required this.categoryTotals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const Center(
        child: Text('Нет данных для отображения'),
      );
    }

    final categoryProvider = Provider.of<CategoryProvider>(context);
    final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    final sections = <PieChartSectionData>[];
    final legends = <Widget>[];
    
    // Цвета для диаграммы
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    int colorIndex = 0;
    categoryTotals.forEach((categoryId, amount) {
      final category = categoryProvider.categories
          .firstWhere((c) => c.id == categoryId, 
                      orElse: () => CategoryModel(id: categoryId, name: 'Неизвестно'));
      final percentage = (amount / total * 100);
      final color = colors[colorIndex % colors.length];

      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

      legends.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                '${amount.toStringAsFixed(2)} ₽',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );

      colorIndex++;
    });

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 0,
              startDegreeOffset: -90,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: legends,
            ),
          ),
        ),
      ],
    );
  }
} 