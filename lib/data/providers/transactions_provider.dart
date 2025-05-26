import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../local/database.dart';
import '../models/transaction_filter.dart';
import 'database_provider.dart';

final transactionFilterProvider = StateProvider<TransactionFilter?>((ref) => null);

final filteredTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  final filter = ref.watch(transactionFilterProvider);

  var query = db.select(db.transactions);

  if (filter != null) {
    if (filter.startDate != null) {
      query = query..where((t) => t.date.isBetween(Variable(filter.startDate!), Variable(filter.startDate!)));
    }
    if (filter.endDate != null) {
      query = query..where((t) => t.date.isBetween(Variable(filter.endDate!), Variable(filter.endDate!)));
    }
    if (filter.isIncome != null) {
      query = query..where((t) => t.isIncome.equals(filter.isIncome!));
    }
    if (filter.categoryId != null) {
      query = query..where((t) => t.categoryId.equals(filter.categoryId!));
    }
  }

  return query.watch();
}); 