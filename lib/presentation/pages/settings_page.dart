import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('Резервное копирование'),
            subtitle: Text('Экспорт и импорт данных'),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Уведомления'),
            subtitle: Text('Настройка уведомлений'),
          ),
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Тема'),
            subtitle: Text('Настройка внешнего вида'),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Язык'),
            subtitle: Text('Выбор языка приложения'),
          ),
          ListTile(
            leading: Icon(Icons.currency_ruble),
            title: Text('Валюта'),
            subtitle: Text('Выбор основной валюты'),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('О приложении'),
            subtitle: Text('Версия и информация'),
          ),
        ],
      ),
    );
  }
} 