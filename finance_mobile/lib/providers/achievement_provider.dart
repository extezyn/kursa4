import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../services/database_service.dart';
import '../models/expense.dart';

class AchievementProvider with ChangeNotifier {
  List<Achievement> _achievements = [];
  
  List<Achievement> get achievements => List.unmodifiable(_achievements);
  List<Achievement> get unlockedAchievements => _achievements.where((a) => a.isUnlocked).toList();
  
  AchievementProvider() {
    loadAchievements();
  }

  Future<void> loadAchievements() async {
    _achievements = await DatabaseService.getAchievements();
    notifyListeners();
  }

  Future<void> checkTransactionAchievements(List<Expense> expenses) async {
    // Первая транзакция
    var firstSteps = _achievements.firstWhere((a) => a.id == 'first_steps');
    if (!firstSteps.isUnlocked && expenses.isNotEmpty) {
      await _updateAchievement('first_steps', 1, true);
    }

    // Первый доход
    var firstIncome = _achievements.firstWhere((a) => a.id == 'first_income');
    if (!firstIncome.isUnlocked && expenses.any((e) => e.isIncome)) {
      await _updateAchievement('first_income', 1, true);
    }

    // Первый расход
    var firstExpense = _achievements.firstWhere((a) => a.id == 'first_expense');
    if (!firstExpense.isUnlocked && expenses.any((e) => !e.isIncome)) {
      await _updateAchievement('first_expense', 1, true);
    }

    // Мастер учета (50 транзакций)
    var transactionMaster = _achievements.firstWhere((a) => a.id == 'transaction_master');
    if (!transactionMaster.isUnlocked) {
      int progress = expenses.length;
      bool isUnlocked = progress >= 50;
      await _updateAchievement('transaction_master', progress, isUnlocked);
    }
  }

  Future<void> checkSavingsAchievements(double monthlyIncome, double monthlyExpense) async {
    if (monthlyIncome <= 0) return;
    
    var savings = ((monthlyIncome - monthlyExpense) / monthlyIncome) * 100;
    
    // Накопитель 10%
    var saver10 = _achievements.firstWhere((a) => a.id == 'saver_10');
    if (!saver10.isUnlocked) {
      int progress = savings.floor();
      bool isUnlocked = savings >= 10;
      await _updateAchievement('saver_10', progress, isUnlocked);
    }

    // Накопитель 20%
    var saver20 = _achievements.firstWhere((a) => a.id == 'saver_20');
    if (!saver20.isUnlocked) {
      int progress = savings.floor();
      bool isUnlocked = savings >= 20;
      await _updateAchievement('saver_20', progress, isUnlocked);
    }
  }

  Future<void> checkCategoryAchievements(int categoryCount) async {
    // Создатель категорий (первая категория)
    var categoryCreator = _achievements.firstWhere((a) => a.id == 'category_creator');
    if (!categoryCreator.isUnlocked && categoryCount >= 1) {
      await _updateAchievement('category_creator', 1, true);
    }

    // Мастер категорий (5 категорий)
    var categoryMaster = _achievements.firstWhere((a) => a.id == 'category_master');
    if (!categoryMaster.isUnlocked) {
      int progress = categoryCount;
      bool isUnlocked = categoryCount >= 5;
      await _updateAchievement('category_master', progress, isUnlocked);
    }
  }

  Future<void> checkRegularUserAchievement() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUsageDate = prefs.getString('last_usage_date');
    final currentDate = DateTime.now().toIso8601String().split('T')[0];
    
    if (lastUsageDate != currentDate) {
      final consecutiveDays = prefs.getInt('consecutive_days') ?? 0;
      final newConsecutiveDays = consecutiveDays + 1;
      
      // Проверяем, не пропущен ли день
      if (lastUsageDate != null) {
        final lastDate = DateTime.parse(lastUsageDate);
        final today = DateTime.parse(currentDate);
        if (today.difference(lastDate).inDays > 1) {
          await prefs.setInt('consecutive_days', 1);
          await prefs.setString('last_usage_date', currentDate);
          await _updateAchievement('regular_user', 1, false);
          return;
        }
      }
      
      await prefs.setInt('consecutive_days', newConsecutiveDays);
      await prefs.setString('last_usage_date', currentDate);
      
      var regularUser = _achievements.firstWhere((a) => a.id == 'regular_user');
      if (!regularUser.isUnlocked) {
        await _updateAchievement('regular_user', newConsecutiveDays, newConsecutiveDays >= 7);
      }
    }
  }

  Future<void> checkBudgetAchievements(bool hasBudget, int monthsWithinBudget) async {
    // Планировщик бюджета
    var budgetPlanner = _achievements.firstWhere((a) => a.id == 'budget_planner');
    if (!budgetPlanner.isUnlocked && hasBudget) {
      await _updateAchievement('budget_planner', 1, true);
    }

    // Мастер бюджета
    var budgetMaster = _achievements.firstWhere((a) => a.id == 'budget_master');
    if (!budgetMaster.isUnlocked) {
      await _updateAchievement('budget_master', monthsWithinBudget, monthsWithinBudget >= 3);
    }
  }

  Future<void> checkIncomeSourceAchievements(int uniqueIncomeSourcesCount) async {
    var incomeDiversification = _achievements.firstWhere((a) => a.id == 'income_diversification');
    if (!incomeDiversification.isUnlocked) {
      await _updateAchievement('income_diversification', uniqueIncomeSourcesCount, uniqueIncomeSourcesCount >= 3);
    }
  }

  Future<void> _updateAchievement(String id, int progress, bool isUnlocked) async {
    var achievement = _achievements.firstWhere((a) => a.id == id);
    var updatedAchievement = achievement.copyWith(
      progress: progress,
      isUnlocked: isUnlocked,
    );
    await DatabaseService.updateAchievement(updatedAchievement);
    await loadAchievements();
  }
} 