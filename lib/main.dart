import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/pages/home_page.dart';
import 'services/notification_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final notificationService = NotificationService();
    await notificationService.initialize();
    debugPrint('Уведомления успешно инициализированы');
    
    runApp(
      const ProviderScope(
        child: FinanceManagerApp(),
      ),
    );
  } catch (e) {
    debugPrint('Ошибка при инициализации приложения: $e');
    rethrow;
  }
}

class FinanceManagerApp extends StatelessWidget {
  const FinanceManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Менеджер финансов',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ru', 'RU'),
      home: const HomePage(),
    );
  }
}
