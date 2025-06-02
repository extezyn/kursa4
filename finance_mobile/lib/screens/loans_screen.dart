import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';
import '../models/loan.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кредиты'),
      ),
      body: Consumer<LoanProvider>(
        builder: (context, provider, child) {
          final loans = provider.loans;
          if (loans.isEmpty) {
            return const Center(
              child: Text('Нет активных кредитов'),
            );
          }

          return ListView.builder(
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Кредит на ${loan.amount} ₽'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ставка: ${loan.interestRate}%'),
                      Text('Срок: ${loan.months} месяцев'),
                      Text('Тип: ${loan.isAnnuity ? "Аннуитетный" : "Дифференцированный"}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteConfirmationDialog(context, loan, provider),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLoanDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddLoanDialog(BuildContext context) async {
    final amountController = TextEditingController();
    final rateController = TextEditingController();
    final monthsController = TextEditingController();
    bool isAnnuity = true;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый кредит'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Сумма кредита',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: rateController,
                decoration: const InputDecoration(
                  labelText: 'Процентная ставка',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: monthsController,
                decoration: const InputDecoration(
                  labelText: 'Срок (месяцев)',
                ),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                title: const Text('Аннуитетный платеж'),
                value: isAnnuity,
                onChanged: (value) {
                  isAnnuity = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (amountController.text.isNotEmpty &&
                  rateController.text.isNotEmpty &&
                  monthsController.text.isNotEmpty) {
                final loan = Loan(
                  id: DateTime.now().toString(),
                  amount: double.parse(amountController.text),
                  interestRate: double.parse(rateController.text),
                  months: int.parse(monthsController.text),
                  isAnnuity: isAnnuity,
                );
                Provider.of<LoanProvider>(context, listen: false).addLoan(loan);
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    Loan loan,
    LoanProvider provider,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить кредит?'),
        content: Text('Вы уверены, что хотите удалить кредит на сумму ${loan.amount} ₽?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteLoan(loan.id);
              Navigator.pop(context);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
} 