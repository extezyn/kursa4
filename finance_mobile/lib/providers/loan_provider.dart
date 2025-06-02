import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../models/loan.dart';
import '../services/database_service.dart';

class LoanProvider with ChangeNotifier {
  List<Loan> _loans = [];

  List<Loan> get loans => List.unmodifiable(_loans);

  Future<void> loadLoans() async {
    _loans = await DatabaseService.getLoans();
    notifyListeners();
  }

  Future<void> addLoan(Loan loan) async {
    await DatabaseService.insertLoan(loan);
    await loadLoans();
  }

  Future<void> updateLoan(Loan loan) async {
    // TODO: Добавить метод updateLoan в DatabaseService
    notifyListeners();
  }

  Future<void> deleteLoan(String id) async {
    // TODO: Добавить метод deleteLoan в DatabaseService
    _loans.removeWhere((loan) => loan.id == id);
    notifyListeners();
  }

  double get totalLoanAmount {
    return _loans.fold(0, (sum, loan) => sum + loan.amount);
  }

  double calculateMonthlyPayment(Loan loan) {
    if (loan.isAnnuity) {
      // Формула для аннуитетного платежа
      final monthlyRate = loan.interestRate / 12 / 100;
      final powValue = math.pow(1 + monthlyRate, loan.months);
      return loan.amount * monthlyRate * powValue / (powValue - 1);
    } else {
      // Формула для дифференцированного платежа
      final principal = loan.amount / loan.months;
      final firstMonthInterest = loan.amount * loan.interestRate / 12 / 100;
      return principal + firstMonthInterest;
    }
  }
}
