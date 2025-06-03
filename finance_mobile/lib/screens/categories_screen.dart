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

  void _showAddCategoryDialog(BuildContext context, bool isIncome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isIncome ? 'Добавить категорию дохода' : 'Добавить категорию расхода'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название категории',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название категории';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedIcon,
                decoration: const InputDecoration(
                  labelText: 'Иконка',
                ),
                items: iconMap.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(entry.value),
                        const SizedBox(width: 8),
                        Text(entry.key),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIcon = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedColor,
                decoration: const InputDecoration(
                  labelText: 'Цвет',
                ),
                items: const [
                  DropdownMenuItem(
                    value: '#4CAF50',
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 12,
                        ),
                        SizedBox(width: 8),
                        Text('Зеленый'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: '#2196F3',
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 12,
                        ),
                        SizedBox(width: 8),
                        Text('Синий'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: '#9C27B0',
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.purple,
                          radius: 12,
                        ),
                        SizedBox(width: 8),
                        Text('Фиолетовый'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedColor = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              Navigator.pop(context);
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final category = CategoryModel(
                  id: DateTime.now().toString(),
                  name: _nameController.text,
                  icon: _selectedIcon,
                  color: _selectedColor,
                  isIncome: isIncome,
                );

                Provider.of<CategoryProvider>(context, listen: false)
                    .addCategory(category);

                _nameController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryModel> categories) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: Icon(
            iconMap[category.icon] ?? Icons.help_outline,
            color: Color(
              int.parse(category.color.replaceAll('#', '0xFF')),
            ),
          ),
          title: Text(category.name),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
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
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('Удалить'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
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
              _buildCategoryList(provider.expenseCategories),
              _buildCategoryList(provider.incomeCategories),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(
          context,
          _tabController.index == 1,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
} 