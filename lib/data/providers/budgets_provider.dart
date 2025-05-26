import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/database.dart';
import '../repositories/budget_repository.dart';
import 'database_provider.dart';
import '../../services/notification_service.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BudgetRepository(db);
});

final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.budgets).watch();
});

final categoryBudgetProvider = StreamProvider.family<Budget?, int>((ref, categoryId) async* {
  final db = ref.watch(databaseProvider);
  
  while (true) {
    final budget = await db.getCurrentBudgetForCategory(categoryId);
    yield budget;
    await db.select(db.budgets).watch().first;
  }
});

final budgetOverrunProvider = StreamProvider.family<Map<String, dynamic>, int>((ref, categoryId) async* {
  final repository = ref.watch(budgetRepositoryProvider);
  final notificationService = NotificationService();
  bool wasOverrun = false;
  
  while (true) {
    final result = await repository.checkBudgetOverrun(categoryId);
    
    // Проверяем превышение бюджета и отправляем уведомление
    if (result['isOverrun'] && !wasOverrun) {
      final budget = result['budget'] as Budget;
      final category = await ref.read(databaseProvider).select(ref.read(databaseProvider).categories)
        .getSingleOrNull();
      
      if (category != null) {
        await notificationService.showBudgetOverrunNotification(
          categoryName: category.name,
          amount: result['amount'],
          limit: budget.amount,
        );
        wasOverrun = true;
      }
    } else if (!result['isOverrun']) {
      wasOverrun = false;
    }
    
    yield result;
    
    // Ждем изменений в транзакциях или бюджетах
    final db = ref.read(databaseProvider);
    await Future.wait([
      db.select(db.transactions).watch().first,
      db.select(db.budgets).watch().first,
    ]);
  }
}); 