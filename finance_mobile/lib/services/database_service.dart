import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/loan.dart';
import '../models/category.dart';
import '../models/achievement.dart';
import '../models/reminder.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'finance.db');

      return await openDatabase(
        path,
        version: 2,
        onCreate: (db, version) async {
          // Создаем таблицу расходов
          await db.execute('''
            CREATE TABLE expenses (
              id TEXT PRIMARY KEY,
              amount REAL NOT NULL,
              date TEXT NOT NULL,
              category TEXT NOT NULL,
              note TEXT,
              isIncome INTEGER NOT NULL
            )
          ''');

          // Создаем таблицу категорий
          await db.execute('''
            CREATE TABLE categories (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              icon TEXT NOT NULL,
              color TEXT NOT NULL,
              isIncome INTEGER NOT NULL DEFAULT 0
            )
          ''');

          // Создаем таблицу достижений
          await db.execute('''
            CREATE TABLE achievements (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              description TEXT NOT NULL,
              icon TEXT NOT NULL,
              targetValue INTEGER NOT NULL,
              progress INTEGER DEFAULT 0,
              isUnlocked INTEGER DEFAULT 0,
              type TEXT NOT NULL
            )
          ''');

          // Создаем таблицу напоминаний
          await db.execute('''
            CREATE TABLE reminders (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              description TEXT,
              date TEXT NOT NULL,
              isCompleted INTEGER DEFAULT 0,
              amount REAL,
              category TEXT,
              isIncome INTEGER DEFAULT 0
            )
          ''');

          // Создаем таблицу кредитов
          await db.execute('''
            CREATE TABLE IF NOT EXISTS loans (
              id TEXT PRIMARY KEY,
              amount REAL NOT NULL,
              description TEXT NOT NULL,
              startDate TEXT NOT NULL,
              endDate TEXT NOT NULL,
              interestRate REAL NOT NULL,
              isActive INTEGER NOT NULL DEFAULT 1,
              isAnnuity INTEGER NOT NULL DEFAULT 1
            )
          ''');

          // Создаем базовые категории
          await db.execute('''
            INSERT INTO categories (id, name, icon, color, isIncome) VALUES
              ('groceries', 'Продукты', 'shopping_cart', '#4CAF50', 0),
              ('cafe', 'Кафе и рестораны', 'restaurant', '#FF9800', 0),
              ('transport', 'Транспорт', 'directions_car', '#2196F3', 0),
              ('entertainment', 'Развлечения', 'movie', '#9C27B0', 0),
              ('health', 'Здоровье', 'local_hospital', '#F44336', 0),
              ('home', 'Жилье', 'home', '#795548', 0),
              ('clothes', 'Одежда', 'checkroom', '#607D8B', 0),
              ('communication', 'Связь', 'phone_android', '#00BCD4', 0),
              ('education', 'Образование', 'school', '#3F51B5', 0),
              ('gifts_exp', 'Подарки', 'card_giftcard', '#E91E63', 0),
              ('salary', 'Зарплата', 'account_balance_wallet', '#4CAF50', 1),
              ('freelance', 'Фриланс', 'computer', '#2196F3', 1),
              ('gifts_inc', 'Подарки', 'redeem', '#E91E63', 1),
              ('investments', 'Инвестиции', 'trending_up', '#FFC107', 1),
              ('business', 'Бизнес', 'business_center', '#009688', 1)
          ''');

          // Создаем базовые достижения
          await db.execute('''
            INSERT INTO achievements (id, name, description, icon, targetValue, type, progress, isUnlocked) VALUES
              ('first_steps', 'Первые шаги', 'Добавьте первую транзакцию', 'edit_note', 1, 'transactions', 0, 0),
              ('first_income', 'Первый доход', 'Добавьте первую запись о доходах', 'payments', 1, 'income', 0, 0),
              ('first_expense', 'Первый расход', 'Добавьте первую запись о расходах', 'shopping_cart', 1, 'expenses', 0, 0)
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            // Добавляем поле isAnnuity в таблицу loans
            await db.execute('ALTER TABLE loans ADD COLUMN isAnnuity INTEGER NOT NULL DEFAULT 1');
          }
        },
      );
    } catch (e) {
      throw Exception('Ошибка инициализации базы данных: $e');
    }
  }

  // Методы для работы с кредитами
  static Future<List<Loan>> getLoans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('loans');
    return List.generate(maps.length, (i) => Loan.fromJson(maps[i]));
  }

  static Future<void> insertLoan(Loan loan) async {
    final db = await database;
    await db.insert(
      'loans',
      loan.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateLoan(Loan loan) async {
    final db = await database;
    await db.update(
      'loans',
      loan.toJson(),
      where: 'id = ?',
      whereArgs: [loan.id],
    );
  }

  static Future<void> deleteLoan(String id) async {
    final db = await database;
    await db.delete(
      'loans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Методы для работы с категориями
  static Future<List<CategoryModel>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');

    return List.generate(maps.length, (i) {
      return CategoryModel(
        id: maps[i]['id'] as String,
        name: maps[i]['name'] as String,
        icon: maps[i]['icon'] as String,
        color: maps[i]['color'] as String,
        isIncome: maps[i]['isIncome'] == 1,
      );
    });
  }

  static Future<void> insertCategory(CategoryModel category) async {
    final db = await database;
    await db.insert(
      'categories',
      {
        'id': category.id,
        'name': category.name,
        'icon': category.icon,
        'color': category.color,
        'isIncome': category.isIncome ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Методы для работы с расходами
  static Future<List<Expense>> getExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');

    return List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'],
        amount: maps[i]['amount'],
        date: DateTime.parse(maps[i]['date']),
        category: maps[i]['category'],
        note: maps[i]['note'],
        isIncome: maps[i]['isIncome'] == 1,
      );
    });
  }

  static Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert(
      'expenses',
      {
        'id': expense.id,
        'amount': expense.amount,
        'date': expense.date.toIso8601String(),
        'category': expense.category,
        'note': expense.note,
        'isIncome': expense.isIncome ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateExpense(Expense expense) async {
    final db = await database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  static Future<void> insertAchievement(Achievement achievement) async {
    final db = await database;
    await db.insert('achievements', {
      'id': achievement.id,
      'name': achievement.name,
      'description': achievement.description,
      'icon': achievement.icon,
      'isUnlocked': achievement.isUnlocked ? 1 : 0,
      'progress': achievement.progress,
      'targetValue': achievement.targetValue,
    });
  }

  static Future<List<Achievement>> getAchievements() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('achievements');

      if (maps.isEmpty) {
        // Если достижений нет, попробуем их создать заново
        await db.execute('''
          INSERT INTO achievements (id, name, description, icon, targetValue, type, progress, isUnlocked) VALUES
            ('first_steps', 'Первые шаги', 'Добавьте первую транзакцию', 'edit_note', 1, 'transactions', 0, 0),
            ('first_income', 'Первый доход', 'Добавьте первую запись о доходах', 'payments', 1, 'income', 0, 0),
            ('first_expense', 'Первый расход', 'Добавьте первую запись о расходах', 'shopping_cart', 1, 'expenses', 0, 0)
          ''');
        return getAchievements();
      }

      return List.generate(maps.length, (i) {
        return Achievement.fromJson({
          'id': maps[i]['id'],
          'name': maps[i]['name'],
          'description': maps[i]['description'],
          'icon': maps[i]['icon'],
          'isUnlocked': maps[i]['isUnlocked'] == 1,
          'progress': maps[i]['progress'],
          'targetValue': maps[i]['targetValue'],
          'type': maps[i]['type'],
        });
      });
    } catch (e) {
      debugPrint('Ошибка при получении достижений: $e');
      return [];
    }
  }

  static Future<void> updateAchievement(Achievement achievement) async {
    final db = await database;
    await db.update(
      'achievements',
      {
        'id': achievement.id,
        'name': achievement.name,
        'description': achievement.description,
        'icon': achievement.icon,
        'isUnlocked': achievement.isUnlocked ? 1 : 0,
        'progress': achievement.progress,
        'targetValue': achievement.targetValue,
      },
      where: 'id = ?',
      whereArgs: [achievement.id],
    );
  }

  static Future<void> insertReminder(Reminder reminder) async {
    final db = await database;
    await db.insert('reminders', reminder.toMap());
  }

  static Future<List<Reminder>> getReminders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reminders');

    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }

  static Future<void> updateReminder(Reminder reminder) async {
    final db = await database;
    await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  static Future<void> deleteReminder(String id) async {
    final db = await database;
    await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearAllData() async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        // Получаем список всех таблиц
        final tables = await txn.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT IN ('android_metadata', 'sqlite_sequence')"
        );
        
        // Удаляем данные из каждой таблицы
        for (var table in tables) {
          final tableName = table['name'] as String;
          await txn.delete(tableName);
        }
      });
    } catch (e) {
      debugPrint('Ошибка при очистке данных: $e');
      // Если произошла ошибка, пробуем удалить данные из известных таблиц
      await db.transaction((txn) async {
        await txn.delete('expenses');
        await txn.delete('categories');
        await txn.delete('achievements');
        await txn.delete('loans');
      });
    }
  }
}