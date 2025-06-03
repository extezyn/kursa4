import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/expense_provider.dart';
import 'providers/loan_provider.dart';
import 'providers/category_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/theme_provider.dart';
import 'services/database_service.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Инициализируем базу данных
    await DatabaseService.initDatabase();
    
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Ошибка инициализации: $e');
    // Показываем экран ошибки
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ошибка запуска приложения',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(
          create: (context) => ExpenseProvider(
            Provider.of<CategoryProvider>(context, listen: false),
            Provider.of<AchievementProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(create: (_) => LoanProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Финансовый менеджер',
            theme: themeProvider.theme,
            home: const AuthenticationWrapper(),
            routes: {
              '/categories': (context) => const CategoriesScreen(),
              '/achievements': (context) => const AchievementsScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isLoading = true;
  bool _requiresAuth = false;
  bool _isAuthenticated = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasPin = prefs.getString('pin') != null;
      final isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
      final isAuthenticated = prefs.getBool('is_authenticated') ?? false;

      if (mounted) {
        setState(() {
          _requiresAuth = hasPin || isBiometricEnabled;
          _isAuthenticated = isAuthenticated;
          _isLoading = false;
        });
      }

      // Проверяем достижение регулярного использования
      if (!_isLoading && mounted) {
        Provider.of<AchievementProvider>(context, listen: false)
            .checkRegularUserAchievement();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ошибка инициализации',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  _checkAuthenticationStatus();
                },
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (_requiresAuth && !_isAuthenticated) {
      return const LockScreen();
    }

    return const HomeScreen();
  }
}
