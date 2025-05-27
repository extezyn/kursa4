import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  String _selectedLanguage = 'Русский';
  String _selectedCurrency = '₽';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
      _selectedLanguage = prefs.getString('language') ?? 'Русский';
      _selectedCurrency = prefs.getString('currency') ?? '₽';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('currency', _selectedCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Тема приложения'),
            subtitle: Text(_themeMode == ThemeMode.system
                ? 'Системная'
                : _themeMode == ThemeMode.light
                    ? 'Светлая'
                    : 'Тёмная'),
            onTap: () async {
              final result = await showDialog<ThemeMode>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('Выберите тему'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, ThemeMode.system),
                      child: const Text('Системная'),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, ThemeMode.light),
                      child: const Text('Светлая'),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, ThemeMode.dark),
                      child: const Text('Тёмная'),
                    ),
                  ],
                ),
              );
              if (result != null) {
                setState(() {
                  _themeMode = result;
                });
                await _saveSettings();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Язык'),
            subtitle: Text(_selectedLanguage),
            onTap: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('Выберите язык'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, 'Русский'),
                      child: const Text('Русский'),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, 'English'),
                      child: const Text('English'),
                    ),
                  ],
                ),
              );
              if (result != null) {
                setState(() {
                  _selectedLanguage = result;
                });
                await _saveSettings();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.currency_ruble),
            title: const Text('Валюта'),
            subtitle: Text(_selectedCurrency),
            onTap: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('Выберите валюту'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, '₽'),
                      child: const Text('Рубль (₽)'),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, '\$'),
                      child: const Text('Доллар (\$)'),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, '€'),
                      child: const Text('Евро (€)'),
                    ),
                  ],
                ),
              );
              if (result != null) {
                setState(() {
                  _selectedCurrency = result;
                });
                await _saveSettings();
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Резервное копирование'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Функция будет доступна в следующей версии'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Восстановление данных'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Функция будет доступна в следующей версии'),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('О приложении'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Финансовый учёт',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Finance Mobile',
              );
            },
          ),
        ],
      ),
    );
  }
} 