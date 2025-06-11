import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isBiometricEnabled = false;
  bool _isPinEnabled = false;
  String _appVersion = '';
  String? _pin;
  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
      _isPinEnabled = prefs.getString('pin') != null;
      _pin = prefs.getString('pin');
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final canAuthenticate = await AuthService.canAuthenticate();
      if (!canAuthenticate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Биометрическая аутентификация недоступна на этом устройстве'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBiometricEnabled', value);
    setState(() {
      _isBiometricEnabled = value;
    });
  }

  Future<void> _togglePin(bool value) async {
    if (value) {
      final pin = await _showPinDialog();
      if (pin != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pin', pin);
        setState(() {
          _isPinEnabled = true;
          _pin = pin;
        });
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pin');
      setState(() {
        _isPinEnabled = false;
        _pin = null;
      });
    }
  }

  Future<String?> _showPinDialog() async {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();
    bool isConfirming = false;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isConfirming ? 'Подтвердите PIN-код' : 'Введите новый PIN-код'),
          content: TextField(
            controller: isConfirming ? confirmPinController : pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'PIN-код',
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (!isConfirming) {
                  if (pinController.text.length != 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN-код должен состоять из 4 цифр')),
                    );
                    return;
                  }
                  setState(() {
                    isConfirming = true;
                  });
                } else {
                  if (pinController.text == confirmPinController.text) {
                    Navigator.pop(context, pinController.text);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN-коды не совпадают')),
                    );
                    confirmPinController.clear();
                  }
                }
              },
              child: Text(isConfirming ? 'Подтвердить' : 'Далее'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить настройки'),
        content: const Text('Вы уверены, что хотите сбросить все настройки к значениям по умолчанию?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        final prefs = await SharedPreferences.getInstance();
        // Сбрасываем только настройки приложения, а не все данные
        await prefs.setBool('isDarkMode', false);
        await prefs.remove('pin');
        
        // Обновляем состояние
        setState(() {
          _isDarkMode = false;
          _isPinEnabled = false;
          _pin = null;
        });

        // Обновляем тему в провайдере
        if (mounted) {
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme(false);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Настройки сброшены'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка при сбросе настроек: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    const url = 'https://example.com/privacy';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось открыть политику конфиденциальности'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchTerms() async {
    const url = 'https://example.com/terms';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось открыть условия использования'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Темная тема'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: _toggleDarkMode,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.pin),
            title: const Text('PIN-код'),
            trailing: Switch(
              value: _isPinEnabled,
              onChanged: _togglePin,
            ),
          ),
          if (_isPinEnabled)
            ListTile(
              leading: const Icon(Icons.pin),
              title: const Text('Изменить PIN-код'),
              onTap: () async {
                final newPin = await _showPinDialog();
                if (newPin != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('pin', newPin);
                  setState(() {
                    _pin = newPin;
                  });
                }
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Сбросить настройки'),
            onTap: _resetSettings,
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Версия приложения'),
            trailing: Text(_appVersion),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
} 