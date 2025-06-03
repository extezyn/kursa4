import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'home_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _pinController = TextEditingController();
  String _enteredPin = '';
  String _errorMessage = '';
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
    });
    if (_isBiometricEnabled && _isBiometricAvailable) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _checkBiometric() async {
    final canAuthenticate = await AuthService.canAuthenticate();
    setState(() {
      _isBiometricAvailable = canAuthenticate;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authenticated = await AuthService.authenticate();
      if (authenticated && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка биометрической аутентификации'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onKeyPressed(String key) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += key;
        _errorMessage = '';
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = '';
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final correctPin = prefs.getString('pin');

      if (correctPin == _enteredPin) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Неверный PIN-код';
          _enteredPin = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Произошла ошибка при проверке PIN-кода';
        _enteredPin = '';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Очищаем базу данных
      await DatabaseService.clearAllData();
      
      // Очищаем настройки
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        // Показываем сообщение об успехе
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Все данные успешно удалены'),
            backgroundColor: Colors.green,
          ),
        );

        // Перезагружаем приложение
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при удалении данных: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showResetConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Сброс данных'),
          content: const Text(
            'Вы уверены, что хотите сбросить пароль? Все данные приложения будут удалены безвозвратно.',
            style: TextStyle(color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetAllData();
              },
              child: const Text(
                'Сбросить',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPinDot(bool isFilled) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? Theme.of(context).primaryColor : Colors.grey[300],
      ),
    );
  }

  Widget _buildKeypadButton(String text, {VoidCallback? onPressed}) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              backgroundColor: Colors.grey[200],
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Введите PIN-код',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => _buildPinDot(index < _enteredPin.length),
              ),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 32),
            if (_isLoading)
              const CircularProgressIndicator()
            else ...[
              for (var i = 0; i < 3; i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (j) => _buildKeypadButton(
                      '${i * 3 + j + 1}',
                      onPressed: () => _onKeyPressed('${i * 3 + j + 1}'),
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildKeypadButton(
                    '',
                    onPressed: null,
                  ),
                  _buildKeypadButton(
                    '0',
                    onPressed: () => _onKeyPressed('0'),
                  ),
                  _buildKeypadButton(
                    '⌫',
                    onPressed: _onBackspacePressed,
                  ),
                ],
              ),
              if (_isBiometricAvailable && _isBiometricEnabled) ...[
                const SizedBox(height: 16),
                IconButton(
                  icon: const Icon(Icons.fingerprint),
                  iconSize: 48,
                  onPressed: _authenticateWithBiometrics,
                ),
              ],
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _showResetConfirmationDialog,
                icon: const Icon(Icons.restore, color: Colors.red),
                label: const Text(
                  'Сбросить пароль',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
} 