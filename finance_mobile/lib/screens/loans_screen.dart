import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';
import '../models/loan.dart';
import 'add_loan_screen.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кредиты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddLoanScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<LoanProvider>(
        builder: (context, loanProvider, child) {
          if (loanProvider.loans.isEmpty) {
            return const Center(
              child: Text('У вас пока нет кредитов'),
            );
          }

          return ListView.builder(
            itemCount: loanProvider.loans.length,
            itemBuilder: (context, index) {
              final loan = loanProvider.loans[index];
              final monthlyPayment = loan.isAnnuity
                  ? loanProvider.calculateAnnuityPayment(loan)
                  : loanProvider.calculateDifferentiatedPayment(loan, 1);
              final totalPayment = loanProvider.calculateTotalPayment(loan);
              final overpayment = loanProvider.calculateOverpayment(loan);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text(
                    'Кредит на ${loan.amount.toStringAsFixed(2)} ₽',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Ставка: ${loan.interestRate}% | Срок: ${loan.months} мес.',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Тип платежа: ${loan.isAnnuity ? "Аннуитетный" : "Дифференцированный"}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ежемесячный платеж: ${monthlyPayment.toStringAsFixed(2)} ₽',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Общая сумма выплат: ${totalPayment.toStringAsFixed(2)} ₽',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Переплата: ${overpayment.toStringAsFixed(2)} ₽',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Удалить кредит'),
                                      content: const Text(
                                        'Вы уверены, что хотите удалить этот кредит?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Отмена'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            loanProvider.deleteLoan(loan.id);
                                            Navigator.pop(context);
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                          child: const Text('Удалить'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                                child: const Text('Удалить'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
} 