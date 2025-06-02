import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import '../providers/achievement_provider.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  final _uuid = const Uuid();
  final AchievementProvider _achievementProvider;

  CategoryProvider(this._achievementProvider) {
    _initializeDefaultCategories();
  }

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<CategoryModel> get expenseCategories => _categories.where((c) => !c.isIncome).toList();
  List<CategoryModel> get incomeCategories => _categories.where((c) => c.isIncome).toList();

  Future<void> _initializeDefaultCategories() async {
    final defaultCategories = [
      // Категории расходов
      CategoryModel(
        id: _uuid.v4(),
        name: 'Продукты',
        isIncome: false,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Транспорт',
        isIncome: false,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Развлечения',
        isIncome: false,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Здоровье',
        isIncome: false,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Коммунальные платежи',
        isIncome: false,
      ),
      // Категории доходов
      CategoryModel(
        id: _uuid.v4(),
        name: 'Зарплата',
        isIncome: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Подработка',
        isIncome: true,
      ),
    ];

    for (var category in defaultCategories) {
      await DatabaseService.insertCategory(category);
    }
    await loadCategories();
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  String getCategoryName(String id) {
    return getCategoryById(id)?.name ?? 'Без категории';
  }

  Future<void> loadCategories() async {
    _categories = await DatabaseService.getCategories();
    notifyListeners();
  }

  Future<void> addCategory(CategoryModel category) async {
    await DatabaseService.insertCategory(category);
    await loadCategories();
    
    // Проверяем достижение "Бюджетный мастер"
    final expenseCategoriesCount = expenseCategories.length;
    await _achievementProvider.checkCategoryAchievements(expenseCategoriesCount);
  }

  Future<void> updateCategory(CategoryModel category) async {
    await DatabaseService.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await DatabaseService.deleteCategory(id);
    await loadCategories();
  }
} 