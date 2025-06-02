import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/credit.dart';
import '../providers/credit_provider.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({Key? key}) : super(key: key);

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _amount = 0;
  double _interestRate = 0;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  double _monthlyPayment = 0;

  void _addCredit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить кредит'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Название'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите название';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Сумма'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите сумму';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Пожалуйста, введите корректное число';
                    }
                    return null;
                  },
                  onSaved: (value) => _amount = double.parse(value!),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Процентная ставка'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите процентную ставку';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Пожалуйста, введите корректное число';
                    }
                    return null;
                  },
                  onSaved: (value) => _interestRate = double.parse(value!),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Ежемесячный платеж'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите ежемесячный платеж';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Пожалуйста, введите корректное число';
                    }
                    return null;
                  },
                  onSaved: (value) => _monthlyPayment = double.parse(value!),
                ),
                ListTile(
                  title: const Text('Дата начала'),
                  subtitle: Text(_startDate.toString().split(' ')[0]),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _startDate = date);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Дата окончания'),
                  subtitle: Text(_endDate.toString().split(' ')[0]),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _endDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                context.read<CreditProvider>().addCredit(
                  name: _name,
                  amount: _amount,
                  interestRate: _interestRate,
                  startDate: _startDate,
                  endDate: _endDate,
                  monthlyPayment: _monthlyPayment,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кредиты'),
      ),
      body: Consumer<CreditProvider>(
        builder: (context, provider, child) {
          final credits = provider.credits;
          return credits.isEmpty
              ? const Center(
                  child: Text('У вас пока нет кредитов'),
                )
              : ListView.builder(
                  itemCount: credits.length,
                  itemBuilder: (context, index) {
                    final credit = credits[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(credit.name),
                        subtitle: Text(
                          'Сумма: ${credit.amount} руб.\n'
                          'Ежемесячный платеж: ${credit.monthlyPayment} руб.\n'
                          'Ставка: ${credit.interestRate}%',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                credit.isPaid ? Icons.check_circle : Icons.check_circle_outline,
                                color: credit.isPaid ? Colors.green : null,
                              ),
                              onPressed: () => provider.toggleCreditPaid(credit.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => provider.deleteCredit(credit.id),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCredit,
        child: const Icon(Icons.add),
      ),
    );
  }
} 