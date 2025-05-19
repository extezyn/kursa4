import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/loan_provider.dart';
import '../utils/loan_calculator.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final loanProvider = Provider.of<LoanProvider>(context);

    final totalExpenses = expenseProvider.expenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Аналитика')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Всего расходов: ${totalExpenses.toStringAsFixed(2)} ₽'),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: loanProvider.loans.length,
                itemBuilder: (context, index) {
                  final loan = loanProvider.loans[index];
                  final monthlyPayment =
                      loan.isAnnuity
                          ? LoanCalculator.calculateAnnuity(
                            loan.amount,
                            loan.interestRate,
                            loan.months,
                          )
                          : LoanCalculator.calculateDifferentiated(
                            loan.amount,
                            loan.interestRate,
                            loan.months,
                          ).first;

                  return ListTile(
                    key: ValueKey(loan.id),
                    title: Text(
                      'Кредит на ${loan.amount.toStringAsFixed(0)} ₽',
                    ),
                    subtitle: Text(
                      'Ежемесячный платёж: ${monthlyPayment.toStringAsFixed(2)} ₽',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
