import 'package:drift/drift.dart';
import '../local/database.dart';

class BudgetRepository {
  final AppDatabase _db;

  BudgetRepository(this._db);

  // Получить все бюджеты
  Future<List<Budget>> getAllBudgets() async {
    return await _db.select(_db.budgets).get();
  }

  // Получить бюджеты за период
  Future<List<Budget>> getBudgetsByPeriod(DateTime startDate, DateTime endDate) async {
    return await (_db.select(_db.budgets)
          ..where((b) => b.startDate.isBiggerOrEqualValue(startDate))
          ..where((b) => b.endDate.isSmallerOrEqualValue(endDate)))
        .get();
  }

  // Получить бюджет по категории
  Future<Budget?> getBudgetByCategory(int categoryId) async {
    return await (_db.select(_db.budgets)
          ..where((b) => b.categoryId.equals(categoryId))
          ..where((b) => b.endDate.isBiggerOrEqualValue(DateTime.now()))
          ..where((b) => b.startDate.isSmallerOrEqualValue(DateTime.now())))
        .getSingleOrNull();
  }

  // Добавить бюджет
  Future<int> addBudget(BudgetsCompanion budget) async {
    return await _db.into(_db.budgets).insert(budget);
  }

  // Обновить бюджет
  Future<bool> updateBudget(BudgetsCompanion budget) async {
    return await _db.update(_db.budgets).replace(budget);
  }

  // Удалить бюджет
  Future<int> deleteBudget(int id) async {
    return await (_db.delete(_db.budgets)..where((b) => b.id.equals(id))).go();
  }

  // Получить текущие расходы по категории за период
  Future<double> getCategoryExpenses(int categoryId, DateTime startDate, DateTime endDate) async {
    final query = _db.select(_db.transactions)
      ..where((t) => t.categoryId.equals(categoryId))
      ..where((t) => t.date.isBetweenValues(startDate, endDate))
      ..where((t) => t.isIncome.equals(false));

    final transactions = await query.get();
    return transactions.fold<double>(0, (sum, t) => sum + t.amount);
  }

  // Проверить превышение бюджета
  Future<Map<String, dynamic>> checkBudgetOverrun(int categoryId) async {
    final budget = await getBudgetByCategory(categoryId);
    if (budget == null) {
      return {'isOverrun': false, 'amount': 0.0, 'percentage': 0.0};
    }

    final expenses = await getCategoryExpenses(
      categoryId,
      budget.startDate,
      budget.endDate,
    );

    final isOverrun = expenses > budget.amount;
    final percentage = (expenses / budget.amount) * 100;

    return {
      'isOverrun': isOverrun,
      'amount': expenses,
      'percentage': percentage,
      'budget': budget,
    };
  }
} 