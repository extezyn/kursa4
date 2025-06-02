import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import 'package:uuid/uuid.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isIncome = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить категорию'),
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
              SwitchListTile(
                title: const Text('Категория дохода'),
                value: _isIncome,
                onChanged: (value) {
                  setState(() {
                    _isIncome = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nameController.clear();
              setState(() {
                _isIncome = false;
              });
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final category = CategoryModel(
                  id: _uuid.v4(),
                  name: _nameController.text,
                  isIncome: _isIncome,
                );
                
                Provider.of<CategoryProvider>(context, listen: false)
                    .addCategory(category);
                
                Navigator.pop(context);
                _nameController.clear();
                setState(() {
                  _isIncome = false;
                });
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Категории'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Расходы'),
              Tab(text: 'Доходы'),
            ],
          ),
        ),
        body: Consumer<CategoryProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [
                _buildCategoryList(provider.expenseCategories),
                _buildCategoryList(provider.incomeCategories),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddCategoryDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryModel> categories) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          title: Text(category.name),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Provider.of<CategoryProvider>(context, listen: false)
                  .deleteCategory(category.id);
            },
          ),
        );
      },
    );
  }
} 