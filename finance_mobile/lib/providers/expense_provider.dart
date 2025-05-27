import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  Future<void> loadExpenses() async {
    _expenses = await DatabaseService.getExpenses();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await DatabaseService.insertExpense(expense);
    _expenses.add(expense);
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await DatabaseService.deleteExpense(id);
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }
}
