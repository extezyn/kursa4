import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Реализовать смену темы
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Язык'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Реализовать смену языка
            },
          ),
          ListTile(
            leading: const Icon(Icons.currency_ruble),
            title: const Text('Валюта'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Реализовать смену валюты
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Резервное копирование'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Реализовать резервное копирование
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Восстановление данных'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Реализовать восстановление данных
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('О приложении'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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