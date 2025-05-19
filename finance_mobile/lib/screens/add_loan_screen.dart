import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/loan.dart';
import '../providers/loan_provider.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({super.key});
  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState(); // Избегаем прямого указания приватного типа
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  final _monthsController = TextEditingController();
  bool _isAnnuity = true;
  String? _errorMessage;

  void _saveLoan() {
    try {
      final amount = double.tryParse(_amountController.text);
      final rate = double.tryParse(_rateController.text);
      final months = int.tryParse(_monthsController.text);

      if (amount == null || amount <= 0) {
        setState(() {
          _errorMessage = 'Введите корректную сумму кредита';
        });
        return;
      }
      if (rate == null || rate < 0) {
        setState(() {
          _errorMessage = 'Введите корректную процентную ставку';
        });
        return;
      }
      if (months == null || months <= 0) {
        setState(() {
          _errorMessage = 'Введите корректный срок в месяцах';
        });
        return;
      }

      final loan = Loan(
        id: Uuid().v4(),
        amount: amount,
        interestRate: rate,
        months: months,
        isAnnuity: _isAnnuity,
      );

      Provider.of<LoanProvider>(context, listen: false).addLoan(loan);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка ввода: проверьте все поля';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить кредит')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Сумма кредита',
                errorText: _errorMessage,
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _rateController,
              decoration: const InputDecoration(labelText: 'Процентная ставка'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _monthsController,
              decoration: const InputDecoration(labelText: 'Срок (в месяцах)'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                const Text('Аннуитетный'),
                Switch(
                  value: _isAnnuity,
                  onChanged: (val) => setState(() => _isAnnuity = val),
                ),
                const Text('Дифференцированный'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveLoan,
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _monthsController.dispose();
    super.dispose();
  }
}
