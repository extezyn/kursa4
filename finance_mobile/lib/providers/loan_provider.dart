import 'package:flutter/foundation.dart';
import '../models/loan.dart';
import '../services/database_service.dart';

class LoanProvider extends ChangeNotifier {
  List<Loan> _loans = [];

  List<Loan> get loans => _loans;

  Future<void> loadLoans() async {
    _loans = await DatabaseService.getLoans();
    notifyListeners();
  }

  Future<void> addLoan(Loan loan) async {
    await DatabaseService.insertLoan(loan);
    _loans.add(loan);
    notifyListeners();
  }
}
