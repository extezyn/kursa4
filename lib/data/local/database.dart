import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  BoolColumn get isIncome => boolean()();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isIncome => boolean()();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
}

@DriftDatabase(tables: [Categories, Transactions, Budgets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Добавляем стандартные категории
        await batch((batch) {
          batch.insertAll(categories, [
            CategoriesCompanion.insert(
              name: 'Продукты',
              icon: '🛒',
              color: '#4CAF50',
              isIncome: false,
            ),
            CategoriesCompanion.insert(
              name: 'Транспорт',
              icon: '🚌',
              color: '#2196F3',
              isIncome: false,
            ),
            CategoriesCompanion.insert(
              name: 'Развлечения',
              icon: '🎮',
              color: '#9C27B0',
              isIncome: false,
            ),
            CategoriesCompanion.insert(
              name: 'Здоровье',
              icon: '💊',
              color: '#F44336',
              isIncome: false,
            ),
            CategoriesCompanion.insert(
              name: 'Зарплата',
              icon: '💰',
              color: '#4CAF50',
              isIncome: true,
            ),
            CategoriesCompanion.insert(
              name: 'Фриланс',
              icon: '💻',
              color: '#2196F3',
              isIncome: true,
            ),
          ]);
        });
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Здесь будут миграции при обновлении схемы
      },
    );
  }

  Future<List<Transaction>> getTransactionsBetweenDates(DateTime start, DateTime end) {
    final startExpr = Variable(start);
    final endExpr = Variable(end);
    return (select(transactions)
          ..where((t) => t.date.isBetween(startExpr, endExpr)))
        .get();
  }

  Future<List<Budget>> getBudgetsBetweenDates(DateTime start, DateTime end) {
    final startExpr = Variable(start);
    final endExpr = Variable(end);
    return (select(budgets)
          ..where((b) => b.startDate.isBetween(startExpr, endExpr) |
              b.endDate.isBetween(startExpr, endExpr)))
        .get();
  }

  Future<Budget?> getCurrentBudgetForCategory(int categoryId) {
    final now = Variable(DateTime.now());
    return (select(budgets)
          ..where((b) => b.categoryId.equals(categoryId) &
              b.startDate.isBetween(now, now) &
              b.endDate.isBetween(now, now)))
        .getSingleOrNull();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'finance_manager.db'));
    return NativeDatabase.createInBackground(file);
  });
} 