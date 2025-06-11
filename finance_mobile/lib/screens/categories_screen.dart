import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedIcon = 'shopping_cart';
  String _selectedColor = '#4CAF50';

  // Предопределенная мапа иконок
  final Map<String, IconData> iconMap = {
    'shopping_cart': Icons.shopping_cart,
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'movie': Icons.movie,
    'local_hospital': Icons.local_hospital,
    'home': Icons.home,
    'checkroom': Icons.checkroom,
    'phone_android': Icons.phone_android,
    'school': Icons.school,
    'card_giftcard': Icons.card_giftcard,
    'account_balance_wallet': Icons.account_balance_wallet,
    'computer': Icons.computer,
    'redeem': Icons.redeem,
    'trending_up': Icons.trending_up,
    'business_center': Icons.business_center,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Расходы'),
            Tab(text: 'Доходы'),
          ],
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Вкладка расходов
              ListView.builder(
                itemCount: provider.expenseCategories.length,
                itemBuilder: (context, index) {
                  final category = provider.expenseCategories[index];
                  return ListTile(
                    leading: Icon(
                      iconMap[category.icon] ?? Icons.category,
                      color: Color(int.parse(category.color.replaceAll('#', '0xFF'))),
                    ),
                    title: Text(category.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteDialog(context, category),
                    ),
                  );
                },
              ),
              // Вкладка доходов
              ListView.builder(
                itemCount: provider.incomeCategories.length,
                itemBuilder: (context, index) {
                  final category = provider.incomeCategories[index];
                  return ListTile(
                    leading: Icon(
                      iconMap[category.icon] ?? Icons.category,
                      color: Color(int.parse(category.color.replaceAll('#', '0xFF'))),
                    ),
                    title: Text(category.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteDialog(context, category),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    bool isIncome = _tabController.index == 1;
    _nameController.clear();
    _selectedIcon = isIncome ? 'account_balance_wallet' : 'shopping_cart';
    _selectedColor = '#4CAF50';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Добавить ${isIncome ? "доход" : "расход"}'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Название категории'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedIcon,
                decoration: const InputDecoration(labelText: 'Иконка'),
                items: iconMap.keys.map((String icon) {
                  return DropdownMenuItem<String>(
                    value: icon,
                    child: Row(
                      children: [
                        Icon(iconMap[icon]),
                        const SizedBox(width: 8),
                        Text(icon),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedIcon = value;
                    });
                  }
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
              if (_formKey.currentState!.validate()) {
                final category = CategoryModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  icon: _selectedIcon,
                  color: _selectedColor,
                  isIncome: isIncome,
                );
                Provider.of<CategoryProvider>(context, listen: false)
                    .addCategory(category);
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, CategoryModel category) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить категорию'),
        content: Text('Вы уверены, что хотите удалить категорию "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CategoryProvider>(context, listen: false)
                  .deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
} 