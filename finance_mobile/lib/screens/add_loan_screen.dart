import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({Key? key}) : super(key: key);

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  final _monthsController = TextEditingController();
  bool _isAnnuity = true;
  bool _isLoading = false;

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите сумму кредита';
    }
    if (double.tryParse(value) == null) {
      return 'Введите корректное число';
    }
    if (double.parse(value) <= 0) {
      return 'Сумма должна быть больше 0';
    }
    return null;
  }

  String? _validateRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите процентную ставку';
    }
    if (double.tryParse(value) == null) {
      return 'Введите корректное число';
    }
    final rate = double.parse(value);
    if (rate <= 0 || rate > 100) {
      return 'Ставка должна быть от 0 до 100';
    }
    return null;
  }

  String? _validateMonths(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите срок кредита';
    }
    if (int.tryParse(value) == null) {
      return 'Введите целое число';
    }
    final months = int.parse(value);
    if (months <= 0 || months > 360) {
      return 'Срок должен быть от 1 до 360 месяцев';
    }
    return null;
  }

  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final rate = double.parse(_rateController.text);
      final months = int.parse(_monthsController.text);

      await Provider.of<LoanProvider>(context, listen: false)
          .addLoan(amount, rate, months, _isAnnuity);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Произошла ошибка при сохранении кредита'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить кредит'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Сумма кредита',
                prefixIcon: Icon(Icons.money),
              ),
              keyboardType: TextInputType.number,
              validator: _validateAmount,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rateController,
              decoration: const InputDecoration(
                labelText: 'Процентная ставка',
                prefixIcon: Icon(Icons.percent),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              validator: _validateRate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _monthsController,
              decoration: const InputDecoration(
                labelText: 'Срок (месяцев)',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
              validator: _validateMonths,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Аннуитетный платеж'),
              subtitle: const Text(
                'Равные ежемесячные платежи на весь срок кредита',
              ),
              value: _isAnnuity,
              onChanged: (value) {
                setState(() {
                  _isAnnuity = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveLoan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
