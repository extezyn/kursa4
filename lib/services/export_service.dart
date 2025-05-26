import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import '../data/local/database.dart';

class ExportService {
  final AppDatabase _db;

  ExportService(this._db);

  Future<String> exportToJson() async {
    final data = {
      'categories': await _db.select(_db.categories).get(),
      'transactions': await _db.select(_db.transactions).get(),
      'budgets': await _db.select(_db.budgets).get(),
    };

    final jsonData = jsonEncode(data);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/finance_manager_backup.json');
    await file.writeAsString(jsonData);

    return file.path;
  }

  Future<void> importFromJson(String filePath) async {
    final file = File(filePath);
    final jsonData = await file.readAsString();
    final data = jsonDecode(jsonData) as Map<String, dynamic>;

    await _db.transaction(() async {
      // Очищаем существующие данные
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.budgets).go();
      await _db.delete(_db.categories).go();

      // Импортируем категории
      for (final categoryData in data['categories'] as List) {
        await _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            name: categoryData['name'] as String,
            icon: categoryData['icon'] as String,
            color: categoryData['color'] as String,
            isIncome: categoryData['isIncome'] as bool,
          ),
        );
      }

      // Импортируем транзакции
      for (final transactionData in data['transactions'] as List) {
        await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            amount: transactionData['amount'] as double,
            categoryId: transactionData['categoryId'] as int,
            description: Value(transactionData['description'] as String?),
            date: DateTime.parse(transactionData['date'] as String),
            isIncome: transactionData['isIncome'] as bool,
          ),
        );
      }

      // Импортируем бюджеты
      for (final budgetData in data['budgets'] as List) {
        await _db.into(_db.budgets).insert(
          BudgetsCompanion.insert(
            categoryId: budgetData['categoryId'] as int,
            amount: budgetData['amount'] as double,
            startDate: DateTime.parse(budgetData['startDate'] as String),
            endDate: DateTime.parse(budgetData['endDate'] as String),
          ),
        );
      }
    });
  }

  Future<String> exportToCsv() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/finance_manager_export.csv');
    final sink = file.openWrite();

    // Заголовки
    sink.writeln('Date,Type,Category,Amount,Description');

    // Получаем все данные
    final transactions = await _db.select(_db.transactions).get();
    final categories = await _db.select(_db.categories).get();

    // Записываем транзакции
    for (final transaction in transactions) {
      final category = categories.firstWhere((c) => c.id == transaction.categoryId);
      sink.writeln(
        '${transaction.date.toIso8601String()},'
        '${transaction.isIncome ? "Income" : "Expense"},'
        '${category.name},'
        '${transaction.amount},'
        '${transaction.description ?? ""}',
      );
    }

    await sink.close();
    return file.path;
  }
} 