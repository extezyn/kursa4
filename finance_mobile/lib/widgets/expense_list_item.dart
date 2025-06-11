import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/category_provider.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExpenseListItem({
    Key? key,
    required this.expense,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final category = categoryProvider.getCategoryById(expense.category);
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            category?.icon == 'shopping_cart' ? Icons.shopping_cart
            : category?.icon == 'restaurant' ? Icons.restaurant
            : category?.icon == 'directions_car' ? Icons.directions_car
            : category?.icon == 'movie' ? Icons.movie
            : category?.icon == 'local_hospital' ? Icons.local_hospital
            : category?.icon == 'home' ? Icons.home
            : category?.icon == 'checkroom' ? Icons.checkroom
            : category?.icon == 'phone_android' ? Icons.phone_android
            : category?.icon == 'school' ? Icons.school
            : category?.icon == 'card_giftcard' ? Icons.card_giftcard
            : category?.icon == 'account_balance_wallet' ? Icons.account_balance_wallet
            : category?.icon == 'computer' ? Icons.computer
            : category?.icon == 'redeem' ? Icons.redeem
            : category?.icon == 'trending_up' ? Icons.trending_up
            : category?.icon == 'business_center' ? Icons.business_center
            : Icons.category,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          categoryProvider.getCategoryName(expense.category),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(dateFormat.format(expense.date)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${expense.isIncome ? '+' : '-'}${expense.amount.toStringAsFixed(2)} ₽',
              style: TextStyle(
                color: expense.isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }
} 