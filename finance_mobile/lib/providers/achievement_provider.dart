import 'package:flutter/foundation.dart';
import '../models/achievement.dart';
import '../data/achievements_data.dart';
import '../services/database_service.dart';

class AchievementProvider with ChangeNotifier {
  List<Achievement> _achievements = [];
  
  List<Achievement> get achievements => _achievements;

  AchievementProvider() {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    // Загружаем достижения из БД или инициализируем начальными значениями
    final savedAchievements = await DatabaseService.getAchievements();
    if (savedAchievements.isEmpty) {
      _achievements = List.from(initialAchievements);
      // Сохраняем начальные достижения в БД
      for (var achievement in _achievements) {
        await DatabaseService.insertAchievement(achievement);
      }
    } else {
      _achievements = savedAchievements;
    }
    notifyListeners();
  }

  Future<void> updateProgress(String achievementId, double progress) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1) {
      final achievement = _achievements[index];
      achievement.progress = progress;
      
      if (progress >= achievement.targetValue && !achievement.isUnlocked) {
        achievement.isUnlocked = true;
        // Здесь можно добавить показ уведомления о разблокировке достижения
      }
      
      await DatabaseService.updateAchievement(achievement);
      notifyListeners();
    }
  }

  Future<void> checkTransactionAchievements(int transactionCount) async {
    // Проверяем достижение "Первые шаги"
    final firstSteps = _achievements.firstWhere((a) => a.id == '1');
    if (!firstSteps.isUnlocked && transactionCount >= 1) {
      await updateProgress('1', 1);
    }
  }

  Future<void> checkCategoryAchievements(int categoryCount) async {
    // Проверяем достижение "Бюджетный мастер"
    final budgetMaster = _achievements.firstWhere((a) => a.id == '2');
    if (!budgetMaster.isUnlocked) {
      await updateProgress('2', categoryCount.toDouble());
    }
  }

  Future<void> checkSavingsAchievements(double plannedBudget, double actualSpent) async {
    // Проверяем достижение "Экономный месяц"
    if (plannedBudget > 0) {
      final savings = _achievements.firstWhere((a) => a.id == '3');
      final savingsPercent = ((plannedBudget - actualSpent) / plannedBudget) * 100;
      if (!savings.isUnlocked && savingsPercent >= 20) {
        await updateProgress('3', 20);
      }
    }
  }

  Future<void> checkLoginStreak(int daysStreak) async {
    // Проверяем достижение "Финансовый эксперт"
    final expert = _achievements.firstWhere((a) => a.id == '5');
    if (!expert.isUnlocked) {
      await updateProgress('5', daysStreak.toDouble());
    }
  }
} 