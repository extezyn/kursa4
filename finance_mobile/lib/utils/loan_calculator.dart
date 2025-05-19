import 'dart:math';

class LoanCalculator {
  static double calculateAnnuity(double amount, double rate, int months) {
    final monthlyRate = rate / 12 / 100;
    return amount * monthlyRate / (1 - pow(1 / (1 + monthlyRate), months));
  }

  static List<double> calculateDifferentiated(
    double amount,
    double rate,
    int months,
  ) {
    double monthlyPrincipal = amount / months;
    List<double> payments = [];

    for (int i = 0; i < months; i++) {
      double remaining = amount - monthlyPrincipal * i;
      double monthlyInterest = remaining * rate / 100 / 12;
      payments.add(monthlyPrincipal + monthlyInterest);
    }

    return payments;
  }
}
