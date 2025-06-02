import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'providers/expense_provider.dart';
import 'providers/loan_provider.dart';
import 'providers/category_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/reminder_provider.dart';
import 'services/database_service.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.initDB();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AchievementProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryProvider(
            Provider.of<AchievementProvider>(context, listen: false),
          )..loadCategories(),
        ),
        ChangeNotifierProvider(
          create: (context) => ExpenseProvider(
            Provider.of<CategoryProvider>(context, listen: false),
            Provider.of<AchievementProvider>(context, listen: false),
          )..loadExpenses(),
        ),
        ChangeNotifierProvider(
          create: (_) => LoanProvider()..loadLoans(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReminderProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Финансовый учёт',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        routes: Routes.getRoutes(),
        initialRoute: Routes.home,
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

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPassword = prefs.getString('app_password') != null;
    final isAuthenticated = prefs.getBool('is_authenticated') ?? false;

    setState(() {
      _requiresAuth = hasPassword;
      _isAuthenticated = isAuthenticated;
      _isLoading = false;
    });
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

    if (_requiresAuth && !_isAuthenticated) {
      return const LockScreen();
    }

    return const HomeScreen();
  }
}
