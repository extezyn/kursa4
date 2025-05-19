class Loan {
  final String id;
  final double amount;
  final double interestRate;
  final int months;
  final bool isAnnuity;

  Loan({
    required this.id,
    required this.amount,
    required this.interestRate,
    required this.months,
    required this.isAnnuity,
  });
}
