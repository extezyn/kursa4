import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;
import '../models/loan.dart';
import '../services/database_service.dart';

class LoanProvider with ChangeNotifier {
  List<Loan> _loans = [];
  final _uuid = const Uuid();

  List<Loan> get loans => List.unmodifiable(_loans);
  List<Loan> get activeLoans => _loans.where((loan) => loan.isActive).toList();

  Future<void> loadLoans() async {
    _loans = await DatabaseService.getLoans();
    notifyListeners();
  }

  Future<void> addLoan(Loan loan) async {
    await DatabaseService.insertLoan(loan);
    await loadLoans();
  }

  Future<void> updateLoan(Loan loan) async {
    await DatabaseService.updateLoan(loan);
    await loadLoans();
  }

  Future<void> deleteLoan(String id) async {
    await DatabaseService.deleteLoan(id);
    await loadLoans();
  }

  double getTotalLoanAmount() {
    return activeLoans.fold(0, (sum, loan) => sum + loan.amount);
  }

  double getTotalInterestAmount() {
    return activeLoans.fold(0, (sum, loan) {
      final durationInYears = loan.endDate.difference(loan.startDate).inDays / 365;
      final interest = loan.amount * (loan.interestRate / 100) * durationInYears;
      return sum + interest;
    });
  }

  // Расчет ежемесячного платежа для аннуитетного кредита
  double calculateAnnuityPayment(Loan loan) {
    final monthlyRate = loan.interestRate / 12 / 100;
    final powValue = math.pow(1 + monthlyRate, loan.months);
    return loan.amount * monthlyRate * powValue / (powValue - 1);
  }

  // Расчет ежемесячного платежа для дифференцированного кредита
  double calculateDifferentiatedPayment(Loan loan, int currentMonth) {
    final mainDebt = loan.amount / loan.months;
    final remainingDebt = loan.amount - (mainDebt * (currentMonth - 1));
    final monthlyInterest = remainingDebt * (loan.interestRate / 12 / 100);
    return mainDebt + monthlyInterest;
  }

  // Расчет общей суммы выплат
  double calculateTotalPayment(Loan loan) {
    if (loan.isAnnuity) {
      return calculateAnnuityPayment(loan) * loan.months;
    } else {
      double total = 0;
      for (int i = 1; i <= loan.months; i++) {
        total += calculateDifferentiatedPayment(loan, i);
      }
      return total;
    }
  }

  // Расчет переплаты
  double calculateOverpayment(Loan loan) {
    return calculateTotalPayment(loan) - loan.amount;
  }
}
