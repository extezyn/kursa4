import 'package:flutter/foundation.dart';
import '../models/credit.dart';
import 'package:uuid/uuid.dart';

class CreditProvider with ChangeNotifier {
  final List<Credit> _credits = [];
  final _uuid = const Uuid();

  List<Credit> get credits => List.unmodifiable(_credits);

  void addCredit({
    required String name,
    required double amount,
    required double interestRate,
    required DateTime startDate,
    required DateTime endDate,
    required double monthlyPayment,
  }) {
    final credit = Credit(
      id: _uuid.v4(),
      name: name,
      amount: amount,
      interestRate: interestRate,
      startDate: startDate,
      endDate: endDate,
      monthlyPayment: monthlyPayment,
    );

    _credits.add(credit);
    notifyListeners();
  }

  void updateCredit(Credit credit) {
    final index = _credits.indexWhere((c) => c.id == credit.id);
    if (index != -1) {
      _credits[index] = credit;
      notifyListeners();
    }
  }

  void deleteCredit(String id) {
    _credits.removeWhere((credit) => credit.id == id);
    notifyListeners();
  }

  void toggleCreditPaid(String id) {
    final index = _credits.indexWhere((c) => c.id == id);
    if (index != -1) {
      _credits[index].isPaid = !_credits[index].isPaid;
      notifyListeners();
    }
  }
} 