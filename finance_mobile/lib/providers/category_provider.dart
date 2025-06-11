import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../providers/achievement_provider.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  final AchievementProvider _achievementProvider;

  CategoryProvider(this._achievementProvider) {
    _initializeCategories();
  }

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  
  List<CategoryModel> get expenseCategories => 
    _categories.where((c) => !c.isIncome).toList();
  
  List<CategoryModel> get incomeCategories => 
    _categories.where((c) => c.isIncome).toList();

  Future<void> _initializeCategories() async {
    await loadCategories();
    if (_categories.isEmpty) {
      await initializeDefaultCategories();
    }
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  String getCategoryName(String id) {
    final category = getCategoryById(id);
    if (category == null) {
      switch (id) {
        case 'groceries':
          return 'Продукты';
        case 'transport':
          return 'Транспорт';
        case 'entertainment':
          return 'Развлечения';
        case 'health':
          return 'Здоровье';
        case 'home':
          return 'Жилье';
        case 'salary':
          return 'Зарплата';
        case 'freelance':
          return 'Фриланс';
        case 'investments':
          return 'Инвестиции';
        default:
          return 'Без категории';
      }
    }
    return category.name;
  }

  Future<void> loadCategories() async {
    _categories = await DatabaseService.getCategories();
    notifyListeners();
  }

  Future<void> addCategory(CategoryModel category) async {
    await DatabaseService.insertCategory(category);
    await loadCategories();
    await _achievementProvider.checkCategoryAchievements(_categories.length);
  }

  Future<void> deleteCategory(String id) async {
    await DatabaseService.deleteCategory(id);
    await loadCategories();
    await _achievementProvider.checkCategoryAchievements(_categories.length);
  }

  Future<void> initializeDefaultCategories() async {
    final defaultCategories = [
      CategoryModel(
        id: 'groceries',
        name: 'Продукты',
        icon: 'shopping_cart',
        color: '#4CAF50',
        isIncome: false,
      ),
      CategoryModel(
        id: 'transport',
        name: 'Транспорт',
        icon: 'directions_car',
        color: '#2196F3',
        isIncome: false,
      ),
      CategoryModel(
        id: 'entertainment',
        name: 'Развлечения',
        icon: 'movie',
        color: '#9C27B0',
        isIncome: false,
      ),
      CategoryModel(
        id: 'health',
        name: 'Здоровье',
        icon: 'local_hospital',
        color: '#F44336',
        isIncome: false,
      ),
      CategoryModel(
        id: 'home',
        name: 'Жилье',
        icon: 'home',
        color: '#795548',
        isIncome: false,
      ),
      CategoryModel(
        id: 'salary',
        name: 'Зарплата',
        icon: 'account_balance_wallet',
        color: '#4CAF50',
        isIncome: true,
      ),
      CategoryModel(
        id: 'freelance',
        name: 'Фриланс',
        icon: 'computer',
        color: '#2196F3',
        isIncome: true,
      ),
      CategoryModel(
        id: 'investments',
        name: 'Инвестиции',
        icon: 'trending_up',
        color: '#FFC107',
        isIncome: true,
      ),
    ];

    for (var category in defaultCategories) {
      await DatabaseService.insertCategory(category);
    }

    await loadCategories();
    await _achievementProvider.checkCategoryAchievements(_categories.length);
  }
} 