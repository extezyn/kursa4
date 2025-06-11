import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../providers/category_provider.dart';
import '../providers/achievement_provider.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;
  final CategoryProvider _categoryProvider;
  final AchievementProvider _achievementProvider;

  ExpenseProvider(this._categoryProvider, this._achievementProvider) {
    loadExpenses();
  }

  // Геттеры для доступа к фильтрам
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get selectedCategory => _selectedCategory;
  CategoryProvider get categoryProvider => _categoryProvider;

  List<Expense> get expenses {
    List<Expense> filteredExpenses = List.from(_expenses);

    if (_startDate != null) {
      filteredExpenses = filteredExpenses
          .where((expense) => expense.date.isAfter(_startDate!))
          .toList();
    }

    if (_endDate != null) {
      filteredExpenses = filteredExpenses
          .where((expense) => expense.date.isBefore(_endDate!.add(const Duration(days: 1))))
          .toList();
    }

    if (_selectedCategory != null) {
      filteredExpenses = filteredExpenses
          .where((expense) => expense.category == _selectedCategory)
          .toList();
    }

    filteredExpenses.sort((a, b) => b.date.compareTo(a.date));

    return filteredExpenses;
  }

  List<Expense> get allExpenses => _expenses;

  void setFilters(DateTime? startDate, DateTime? endDate, String? category) {
    _startDate = startDate;
    _endDate = endDate;
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadExpenses() async {
    _expenses = await DatabaseService.getExpenses();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await DatabaseService.insertExpense(expense);
    await loadExpenses();
    
    // Проверяем достижения
    await _achievementProvider.checkTransactionAchievements(_expenses);
    
    // Проверяем достижения экономии
    final monthStart = DateTime(expense.date.year, expense.date.month, 1);
    final monthEnd = DateTime(expense.date.year, expense.date.month + 1, 0);
    
    final monthlyTransactions = _expenses.where((e) => 
      e.date.isAfter(monthStart) && 
      e.date.isBefore(monthEnd)
    );
    
    final monthlyIncome = monthlyTransactions
      .where((e) => e.isIncome)
      .fold(0.0, (sum, e) => sum + e.amount);
    
    final monthlyExpense = monthlyTransactions
      .where((e) => !e.isIncome)
      .fold(0.0, (sum, e) => sum + e.amount);
    
    await _achievementProvider.checkSavingsAchievements(monthlyIncome, monthlyExpense);

    // Проверяем достижение разнообразия доходов
    final uniqueIncomeCategories = _expenses
      .where((e) => e.isIncome)
      .map((e) => e.category)
      .toSet()
      .length;
    
    await _achievementProvider.checkIncomeSourceAchievements(uniqueIncomeCategories);
    
    // Проверяем достижение регулярного использования
    await _achievementProvider.checkRegularUserAchievement();
  }

  Future<void> updateExpense(Expense expense) async {
    await DatabaseService.updateExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await DatabaseService.deleteExpense(id);
    await loadExpenses();
  }

  double get totalIncome {
    return expenses
        .where((expense) => expense.isIncome)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  double get totalExpense {
    return expenses
        .where((expense) => !expense.isIncome)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  double get balance => totalIncome - totalExpense;

  Map<String, double> getCategoryTotals({bool onlyExpenses = false}) {
    final Map<String, double> totals = {};
    
    final filteredExpenses = onlyExpenses 
        ? expenses.where((e) => !e.isIncome).toList()
        : expenses;

    for (var expense in filteredExpenses) {
      if (totals.containsKey(expense.category)) {
        totals[expense.category] = totals[expense.category]! + expense.amount;
      } else {
        totals[expense.category] = expense.amount;
      }
    }
    
    return totals;
  }
}
