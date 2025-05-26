import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/transactions_provider.dart';
import 'add_edit_transaction_page.dart';
import 'filter_transactions_page.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Транзакции'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FilterTransactionsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: transactions.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(
              child: Text('Нет транзакций'),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: transaction.isIncome ? Colors.green : Colors.red,
                  child: Icon(
                    transaction.isIncome ? Icons.add : Icons.remove,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  transaction.description ?? 'Без описания',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  '${transaction.date.day}.${transaction.date.month}.${transaction.date.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Text(
                  '${transaction.isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ₽',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: transaction.isIncome ? Colors.green : Colors.red,
                      ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditTransactionPage(
                        transaction: transaction,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditTransactionPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 