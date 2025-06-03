import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../services/database_service.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];

  CategoryProvider() {
    _initializeCategories();
  }

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<CategoryModel> get expenseCategories => _categories.where((c) => !c.isIncome).toList();
  List<CategoryModel> get incomeCategories => _categories.where((c) => c.isIncome).toList();

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
    return getCategoryById(id)?.name ?? 'Без категории';
  }

  Future<void> loadCategories() async {
    _categories = await DatabaseService.getCategories();
    notifyListeners();
  }

  Future<void> addCategory(CategoryModel category) async {
    await DatabaseService.insertCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadCategories();
  }

  Future<void> initializeDefaultCategories() async {
    if (_categories.isEmpty) {
      final defaultCategories = [
        CategoryModel(
          id: '1',
          name: 'Продукты',
          icon: 'shopping_cart',
          color: '#4CAF50',
        ),
        CategoryModel(
          id: '2',
          name: 'Транспорт',
          icon: 'directions_car',
          color: '#2196F3',
        ),
        CategoryModel(
          id: '3',
          name: 'Развлечения',
          icon: 'movie',
          color: '#9C27B0',
        ),
        CategoryModel(
          id: '4',
          name: 'Зарплата',
          icon: 'work',
          color: '#4CAF50',
          isIncome: true,
        ),
        CategoryModel(
          id: '5',
          name: 'Фриланс',
          icon: 'computer',
          color: '#2196F3',
          isIncome: true,
        ),
      ];

      for (var category in defaultCategories) {
        await DatabaseService.insertCategory(category);
      }

      await loadCategories();
    }
  }
} 