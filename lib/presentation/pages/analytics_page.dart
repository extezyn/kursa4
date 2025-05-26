import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../data/providers/analytics_provider.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  late DateTimeRange _dateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsProvider(_dateRange));
    final numberFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналитика'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: analytics.when(
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Общая статистика
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Общая статистика',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StatisticRow(
                      label: 'Доходы',
                      amount: data.totalIncome,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _StatisticRow(
                      label: 'Расходы',
                      amount: data.totalExpense,
                      color: Colors.red,
                    ),
                    const Divider(),
                    _StatisticRow(
                      label: 'Баланс',
                      amount: data.balance,
                      color: data.balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // График расходов по категориям
            if (data.categoryExpenses.isNotEmpty) ...[
              const Text(
                'Расходы по категориям',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: data.categoryExpenses
                        .map((category) => PieChartSectionData(
                              value: category.amount,
                              title: '${category.category.name}\n${numberFormat.format(category.amount)}',
                              color: Color(int.parse(category.category.color.replaceFirst('#', '0xFF'))),
                              radius: 100,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ))
                        .toList(),
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // График доходов и расходов по дням
            if (data.dailyExpenses.isNotEmpty || data.dailyIncomes.isNotEmpty) ...[
              const Text(
                'Динамика доходов и расходов',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < data.dailyExpenses.length) {
                              final date = data.dailyExpenses[value.toInt()].date;
                              return Text(
                                '${date.day}',
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      // Расходы
                      LineChartBarData(
                        spots: data.dailyExpenses
                            .asMap()
                            .entries
                            .map((e) => FlSpot(
                                  e.key.toDouble(),
                                  e.value.amount,
                                ))
                            .toList(),
                        color: Colors.red,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      ),
                      // Доходы
                      LineChartBarData(
                        spots: data.dailyIncomes
                            .asMap()
                            .entries
                            .map((e) => FlSpot(
                                  e.key.toDouble(),
                                  e.value.amount,
                                ))
                            .toList(),
                        color: Colors.green,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }
}

class _StatisticRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _StatisticRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          numberFormat.format(amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 