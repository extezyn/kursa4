import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../services/database_service.dart';

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

  Future<void> checkTransactionAchievements(int transactionCount) async {
    var firstExpense = _achievements.firstWhere((a) => a.id == 'first_expense');
    if (!firstExpense.isUnlocked && transactionCount >= 1) {
      await unlockAchievement('first_expense');
    }
  }

  Future<void> checkSavingsAchievements(double planned, double actual) async {
    if (planned <= 0) return;
    
    var savings = ((planned - actual) / planned) * 100;
    var savingsMaster = _achievements.firstWhere((a) => a.id == 'savings_master');
    
    if (!savingsMaster.isUnlocked && savings >= 20) {
      await unlockAchievement('savings_master');
    }
  }

  Future<void> checkCategoryAchievements(int categoryCount) async {
    var categoryExpert = _achievements.firstWhere((a) => a.id == 'category_expert');
    if (!categoryExpert.isUnlocked && categoryCount >= 5) {
      await unlockAchievement('category_expert');
    }
  }

  Future<void> checkBigSpenderAchievement(double amount) async {
    var bigSpender = _achievements.firstWhere((a) => a.id == 'big_spender');
    if (!bigSpender.isUnlocked && amount >= 100000) {
      await unlockAchievement('big_spender');
    }
  }

  Future<void> checkRegularUserAchievement() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUsageDate = prefs.getString('last_usage_date');
    final currentDate = DateTime.now().toIso8601String().split('T')[0];
    
    if (lastUsageDate != currentDate) {
      final consecutiveDays = prefs.getInt('consecutive_days') ?? 0;
      await prefs.setInt('consecutive_days', consecutiveDays + 1);
      await prefs.setString('last_usage_date', currentDate);
      
      var regularUser = _achievements.firstWhere((a) => a.id == 'regular_user');
      if (!regularUser.isUnlocked && consecutiveDays + 1 >= 7) {
        await unlockAchievement('regular_user');
      }
    }
  }

  Future<void> unlockAchievement(String id) async {
    var achievement = _achievements.firstWhere((a) => a.id == id);
    achievement = achievement.copyWith(isUnlocked: true, progress: achievement.targetValue);
    await DatabaseService.updateAchievement(achievement);
    await loadAchievements();
  }
} 