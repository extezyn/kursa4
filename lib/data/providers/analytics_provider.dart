import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../local/database.dart';
import 'database_provider.dart';

class AnalyticsData {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<CategorySum> categoryExpenses;
  final List<CategorySum> categoryIncomes;
  final List<DailySum> dailyExpenses;
  final List<DailySum> dailyIncomes;

  AnalyticsData({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.categoryExpenses,
    required this.categoryIncomes,
    required this.dailyExpenses,
    required this.dailyIncomes,
  });
}

class CategorySum {
  final Category category;
  final double amount;
  final double percentage;

  CategorySum({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class DailySum {
  final DateTime date;
  final double amount;

  DailySum({
    required this.date,
    required this.amount,
  });
}

final analyticsProvider = StreamProvider.family<AnalyticsData, DateTimeRange>((ref, dateRange) async* {
  final db = ref.watch(databaseProvider);

  while (true) {
    // Получаем все транзакции за период
    final transactions = await db.getTransactionsBetweenDates(
      dateRange.start,
      dateRange.end,
    );

    // Получаем все категории
    final categories = await db.select(db.categories).get();

    // Вычисляем общие суммы
    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final totalExpense = transactions
        .where((t) => !t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);

    // Группируем транзакции по категориям
    final categoryExpenses = <CategorySum>[];
    final categoryIncomes = <CategorySum>[];

    for (final category in categories) {
      final categoryTransactions = transactions
          .where((t) => t.categoryId == category.id && t.isIncome == category.isIncome)
          .toList();

      final sum = categoryTransactions.fold<double>(0, (sum, t) => sum + t.amount);
      final total = category.isIncome ? totalIncome : totalExpense;
      final percentage = total > 0 ? (sum / total * 100) : 0.0;

      final categorySum = CategorySum(
        category: category,
        amount: sum,
        percentage: percentage,
      );

      if (category.isIncome) {
        categoryIncomes.add(categorySum);
      } else {
        categoryExpenses.add(categorySum);
      }
    }

    // Группируем транзакции по дням
    final dailyExpenses = <DailySum>[];
    final dailyIncomes = <DailySum>[];

    for (var date = dateRange.start;
        date.isBefore(dateRange.end) || date.isAtSameMomentAs(dateRange.end);
        date = date.add(const Duration(days: 1))) {
      final dayTransactions = transactions
          .where((t) =>
              t.date.year == date.year &&
              t.date.month == date.month &&
              t.date.day == date.day)
          .toList();

      final dayIncome = dayTransactions
          .where((t) => t.isIncome)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final dayExpense = dayTransactions
          .where((t) => !t.isIncome)
          .fold<double>(0, (sum, t) => sum + t.amount);

      if (dayIncome > 0) {
        dailyIncomes.add(DailySum(date: date, amount: dayIncome));
      }
      if (dayExpense > 0) {
        dailyExpenses.add(DailySum(date: date, amount: dayExpense));
      }
    }

    yield AnalyticsData(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      categoryExpenses: categoryExpenses,
      categoryIncomes: categoryIncomes,
      dailyExpenses: dailyExpenses,
      dailyIncomes: dailyIncomes,
    );

    // Ждем изменений в базе данных
    await db.select(db.transactions).watch().first;
  }
}); 