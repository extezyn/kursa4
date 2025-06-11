import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/loan.dart';
import '../providers/loan_provider.dart';
import 'package:uuid/uuid.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({Key? key}) : super(key: key);

  void _showAddLoanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditLoanDialog(),
    );
  }

  void _showEditLoanDialog(BuildContext context, Loan loan) {
    showDialog(
      context: context,
      builder: (context) => AddEditLoanDialog(loan: loan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кредиты'),
      ),
      body: Consumer<LoanProvider>(
        builder: (context, provider, child) {
          if (provider.loans.isEmpty) {
            return const Center(
              child: Text('Нет активных кредитов'),
            );
          }

          return ListView.builder(
            itemCount: provider.loans.length,
            itemBuilder: (context, index) {
              final loan = provider.loans[index];
              final dateFormat = DateFormat('dd.MM.yyyy');
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(loan.description),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Сумма: ${loan.amount.toStringAsFixed(2)} ₽'),
                      Text('Ставка: ${loan.interestRate}%'),
                      Text(
                        'Период: ${dateFormat.format(loan.startDate)} - ${dateFormat.format(loan.endDate)}',
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditLoanDialog(context, loan),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Удалить кредит'),
                              content: const Text('Вы уверены, что хотите удалить этот кредит?'),
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
                        },
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
        onPressed: () => _showAddLoanDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddEditLoanDialog extends StatefulWidget {
  final Loan? loan;

  const AddEditLoanDialog({Key? key, this.loan}) : super(key: key);

  @override
  State<AddEditLoanDialog> createState() => _AddEditLoanDialogState();
}

class _AddEditLoanDialogState extends State<AddEditLoanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _interestRateController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  bool _isAnnuity = false;

  @override
  void initState() {
    super.initState();
    if (widget.loan != null) {
      _amountController.text = widget.loan!.amount.toString();
      _descriptionController.text = widget.loan!.description;
      _interestRateController.text = widget.loan!.interestRate.toString();
      _startDate = widget.loan!.startDate;
      _endDate = widget.loan!.endDate;
      _isAnnuity = widget.loan!.isAnnuity;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final loan = Loan(
        id: widget.loan?.id ?? const Uuid().v4(),
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
        interestRate: double.parse(_interestRateController.text),
        isAnnuity: _isAnnuity,
      );

      if (widget.loan != null) {
        Provider.of<LoanProvider>(context, listen: false).updateLoan(loan);
      } else {
        Provider.of<LoanProvider>(context, listen: false).addLoan(loan);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return AlertDialog(
      title: Text(widget.loan == null ? 'Добавить кредит' : 'Редактировать кредит'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Сумма',
                  prefixText: '₽ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите сумму';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Введите корректное число';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите описание';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _interestRateController,
                decoration: const InputDecoration(
                  labelText: 'Процентная ставка',
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите процентную ставку';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Введите корректное число';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Аннуитетный платеж'),
                subtitle: const Text('Равные ежемесячные платежи'),
                value: _isAnnuity,
                onChanged: (bool value) {
                  setState(() {
                    _isAnnuity = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectDate(context, true),
                      child: Text('Начало: ${dateFormat.format(_startDate)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectDate(context, false),
                      child: Text('Конец: ${dateFormat.format(_endDate)}'),
                    ),
                  ),
                ],
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
          onPressed: _submitForm,
          child: Text(widget.loan == null ? 'Добавить' : 'Сохранить'),
        ),
      ],
    );
  }
} 