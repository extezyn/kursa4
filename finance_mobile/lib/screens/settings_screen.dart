import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _currency = 'RUB';
  bool _isPasswordEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadSettings();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPasswordEnabled = prefs.getBool('password_enabled') ?? false;
    });
  }

  Future<void> _togglePasswordProtection(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      // Включаем защиту паролем
      final password = await _showPasswordDialog();
      if (password != null && password.isNotEmpty) {
        await prefs.setString('app_password', password);
        await prefs.setBool('password_enabled', true);
        // Устанавливаем флаг аутентификации при создании PIN-кода
        await prefs.setBool('is_authenticated', true);
        setState(() {
          _isPasswordEnabled = true;
        });
      }
    } else {
      // Отключаем защиту паролем
      final confirmed = await _showConfirmationDialog();
      if (confirmed) {
        await prefs.remove('app_password');
        await prefs.setBool('password_enabled', false);
        // Удаляем флаг аутентификации при отключении PIN-кода
        await prefs.remove('is_authenticated');
        setState(() {
          _isPasswordEnabled = false;
        });
      }
    }
  }

  Future<String?> _showPasswordDialog() async {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    String? errorText;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Установить PIN-код'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                decoration: const InputDecoration(
                  labelText: 'Введите PIN-код',
                  prefixIcon: Icon(Icons.password),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  labelText: 'Подтвердите PIN-код',
                  prefixIcon: const Icon(Icons.password),
                  errorText: errorText,
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (passwordController.text.length != 4) {
                  setState(() {
                    errorText = 'PIN-код должен состоять из 4 цифр';
                  });
                  return;
                }
                if (passwordController.text.isEmpty || 
                    confirmPasswordController.text.isEmpty) {
                  setState(() {
                    errorText = 'PIN-код не может быть пустым';
                  });
                  return;
                }
                if (passwordController.text != confirmPasswordController.text) {
                  setState(() {
                    errorText = 'PIN-коды не совпадают';
                  });
                  return;
                }
                Navigator.pop(context, passwordController.text);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отключить защиту'),
        content: const Text('Вы уверены, что хотите отключить защиту PIN-кодом?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Отключить'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _changePassword() async {
    final newPassword = await _showPasswordDialog();
    if (newPassword != null && newPassword.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_password', newPassword);
      // Обновляем флаг аутентификации при смене PIN-кода
      await prefs.setBool('is_authenticated', true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN-код успешно изменен')),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти? Потребуется повторный ввод PIN-кода.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', false);
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Безопасность',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Защита PIN-кодом'),
            subtitle: const Text('Запрашивать PIN-код при входе в приложение'),
            value: _isPasswordEnabled,
            onChanged: _togglePasswordProtection,
          ),
          if (_isPasswordEnabled) ...[
            ListTile(
              title: const Text('Изменить PIN-код'),
              leading: const Icon(Icons.password),
              onTap: _changePassword,
            ),
            ListTile(
              title: const Text('Выйти'),
              leading: const Icon(Icons.logout),
              textColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
              onTap: _logout,
            ),
          ],
          const Divider(),
          SwitchListTile(
            title: const Text('Темная тема'),
            subtitle: const Text('Включить темную тему приложения'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
                // TODO: Implement theme change
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Уведомления'),
            subtitle: const Text('Включить push-уведомления'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                // TODO: Implement notifications toggle
              });
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Валюта'),
            subtitle: Text('Текущая валюта: $_currency'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Выберите валюту'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile(
                        title: const Text('Рубль (RUB)'),
                        value: 'RUB',
                        groupValue: _currency,
                        onChanged: (value) {
                          setState(() {
                            _currency = value.toString();
                          });
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile(
                        title: const Text('Доллар (USD)'),
                        value: 'USD',
                        groupValue: _currency,
                        onChanged: (value) {
                          setState(() {
                            _currency = value.toString();
                          });
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile(
                        title: const Text('Евро (EUR)'),
                        value: 'EUR',
                        groupValue: _currency,
                        onChanged: (value) {
                          setState(() {
                            _currency = value.toString();
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('О приложении'),
            subtitle: Text('Версия $_version'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Финансовый менеджер',
                applicationVersion: _version,
                applicationIcon: const Icon(Icons.account_balance_wallet),
                children: const [
                  Text('Приложение для управления личными финансами'),
                ],
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Документы',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Политика конфиденциальности'),
            onTap: () async {
              const url = 'https://example.com/privacy';
              if (await canLaunch(url)) {
                await launch(url);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Условия использования'),
            onTap: () async {
              const url = 'https://example.com/terms';
              if (await canLaunch(url)) {
                await launch(url);
              }
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Разработка',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('Сообщить о проблеме'),
            onTap: () {
              // TODO: Implement bug report
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Оценить приложение'),
            onTap: () {
              // TODO: Implement app rating
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '© 2025 Finance App',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 