import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isPasswordVisible = false;
  int _failedAttempts = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _loadFailedAttempts();
  }

  Future<void> _loadFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _failedAttempts = prefs.getInt('failed_attempts') ?? 0;
    });
  }

  Future<void> _saveFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('failed_attempts', _failedAttempts);
  }

  void _onPasswordChanged() {
    if (_passwordController.text.length > 4) {
      _passwordController.text = _passwordController.text.substring(0, 4);
      _passwordController.selection = TextSelection.fromPosition(
        TextPosition(offset: _passwordController.text.length),
      );
    }
  }

  Future<void> _checkPassword() async {
    if (_passwordController.text.length != 4) {
      setState(() {
        _errorMessage = 'PIN-код должен состоять из 4 символов';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('app_password');

    if (savedPassword == _passwordController.text) {
      await prefs.setInt('failed_attempts', 0);
      await prefs.setBool('is_authenticated', true);
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (Route<dynamic> route) => false,
      );
    } else {
      setState(() {
        _failedAttempts++;
        _errorMessage = 'Неверный PIN-код';
        _passwordController.clear();
      });
      await _saveFailedAttempts();
    }
  }

  Future<void> _resetPinAndData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Сброс PIN-кода'),
        content: const Text(
          'ВНИМАНИЕ! Это действие приведет к полному удалению всех данных:\n\n'
          '• Все транзакции\n'
          '• Все кредиты\n'
          '• Все категории\n'
          '• Все настройки\n\n'
          'Это действие необратимо. Вы уверены, что хотите продолжить?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сбросить всё'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final prefs = await SharedPreferences.getInstance();
        // Инициализируем базу данных перед очисткой
        await DatabaseService.initDB();
        // Очищаем все данные из базы
        await DatabaseService.clearAllData();
        // Очищаем все настройки
        await prefs.clear();
        
        // Закрываем диалог загрузки и перезапускаем приложение
        Navigator.of(context).pop(); // Закрываем индикатор загрузки
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        // В случае ошибки закрываем диалог загрузки и показываем сообщение об ошибке
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Произошла ошибка при сбросе данных'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Введите PIN-код',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (_failedAttempts > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Неудачных попыток: $_failedAttempts',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 4,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    labelText: 'PIN-код',
                    errorText: _errorMessage,
                    counterText: '',
                    prefixIcon: const Icon(Icons.password),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  onSubmitted: (_) => _checkPassword(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkPassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: const Text('Войти'),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _resetPinAndData,
                icon: const Icon(Icons.restore),
                label: const Text('Сбросить PIN-код'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Внимание: сброс PIN-кода приведет к удалению всех данных',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 