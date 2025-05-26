import 'package:drift/drift.dart';
import '../local/database.dart';

class TransactionRepository {
  final AppDatabase _db;

  TransactionRepository(this._db);

  // Получить все транзакции
  Future<List<Transaction>> getAllTransactions() {
    return _db.select(_db.transactions).get();
  }

  // Получить транзакции за период
  Future<List<Transaction>> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    final startExpr = Variable(start);
    final endExpr = Variable(end);
    return (_db.select(_db.transactions)
          ..where((t) => t.date.isBetween(startExpr, endExpr)))
        .get();
  }

  // Добавить транзакцию
  Future<int> addTransaction(TransactionsCompanion transaction) {
    return _db.into(_db.transactions).insert(transaction);
  }

  // Обновить транзакцию
  Future<bool> updateTransaction(Transaction transaction) {
    return _db.update(_db.transactions).replace(transaction);
  }

  // Удалить транзакцию
  Future<int> deleteTransaction(int id) {
    return (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  // Получить сумму по типу (доход/расход) за период
  Future<double> getAmountByType(
    bool isIncome,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query = _db.select(_db.transactions)
      ..where((t) => t.isIncome.equals(isIncome))
      ..where((t) => t.date.isBetween(Variable(startDate), Variable(endDate)));

    final amounts = await query.map((row) => row.amount).get();
    return amounts.fold<double>(0, (sum, amount) => sum + amount);
  }

  Future<List<Transaction>> getTransactionsByCategory(int categoryId) {
    return (_db.select(_db.transactions)
          ..where((t) => t.categoryId.equals(categoryId)))
        .get();
  }

  Future<double> getTotalAmountForCategory(
      int categoryId, DateTime start, DateTime end) async {
    final transactions = await getTransactionsByDateRange(start, end);
    return transactions
        .where((t) => t.categoryId == categoryId)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }
}
