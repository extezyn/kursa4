import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/loans_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/categories_screen.dart';

class Routes {
  static const String home = '/';
  static const String expenses = '/expenses';
  static const String loans = '/loans';
  static const String achievements = '/achievements';
  static const String reminders = '/reminders';
  static const String categories = '/categories';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      expenses: (context) => const ExpensesScreen(),
      loans: (context) => const LoansScreen(),
      achievements: (context) => const AchievementsScreen(),
      reminders: (context) => const RemindersScreen(),
      categories: (context) => const CategoriesScreen(),
    };
  }
} 