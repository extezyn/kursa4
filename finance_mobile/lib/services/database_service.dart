import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/loan.dart';
import '../models/category.dart';
import '../models/achievement.dart';
import '../models/reminder.dart';

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
        version: 1,
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
              color TEXT NOT NULL
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

          // Создаем таблицу кредитов
          await db.execute('''
            CREATE TABLE loans (
              id TEXT PRIMARY KEY,
              amount REAL NOT NULL,
              interestRate REAL NOT NULL,
              months INTEGER NOT NULL,
              isAnnuity INTEGER NOT NULL
            )
          ''');

          // Создаем базовые категории
          await db.execute('''
            INSERT INTO categories (id, name, icon, color) VALUES
              ('groceries', 'Продукты', 'shopping_cart', '#4CAF50'),
              ('cafe', 'Кафе и рестораны', 'restaurant', '#FF9800'),
              ('transport', 'Транспорт', 'directions_car', '#2196F3'),
              ('entertainment', 'Развлечения', 'movie', '#9C27B0'),
              ('health', 'Здоровье', 'local_hospital', '#F44336'),
              ('home', 'Жилье', 'home', '#795548'),
              ('clothes', 'Одежда', 'checkroom', '#607D8B'),
              ('communication', 'Связь', 'phone_android', '#00BCD4'),
              ('education', 'Образование', 'school', '#3F51B5'),
              ('gifts_exp', 'Подарки', 'card_giftcard', '#E91E63'),
              ('salary', 'Зарплата', 'account_balance_wallet', '#4CAF50'),
              ('freelance', 'Фриланс', 'computer', '#2196F3'),
              ('gifts_inc', 'Подарки', 'redeem', '#E91E63'),
              ('investments', 'Инвестиции', 'trending_up', '#FFC107'),
              ('business', 'Бизнес', 'business_center', '#009688')
          ''');

          // Создаем базовые достижения
          await db.execute('''
            INSERT INTO achievements (id, name, description, icon, targetValue, type, progress, isUnlocked) VALUES
              ('first_transaction', 'Первая запись', 'Создайте первую запись о расходах или доходах', 'edit_note', 1, 'transactions', 0, 0),
              ('first_category', 'Первая категория', 'Создайте свою первую категорию', 'category', 1, 'categories', 0, 0),
              ('first_income', 'Первый доход', 'Добавьте первую запись о доходе', 'payments', 1, 'income', 0, 0),
              ('week_usage', '7 дней использования', 'Используйте приложение 7 дней подряд', 'calendar_month', 7, 'usage_days', 0, 0),
              ('hundred_transactions', '100 транзакций', 'Создайте 100 записей о расходах и доходах', 'format_list_numbered', 100, 'transactions', 0, 0),
              ('positive_month', 'Положительный месяц', 'Сохраняйте положительный баланс целый месяц', 'trending_up', 30, 'balance_days', 0, 0),
              ('savings_goal', 'Цель накопления', 'Достигните поставленной цели накопления', 'flag', 1, 'savings_goal', 0, 0),
              ('five_categories', '5 категорий', 'Создайте 5 собственных категорий', 'category', 5, 'categories', 0, 0),
              ('savings_10', 'Накопление 10%', 'Накопите 10% от месячного дохода', 'savings', 10, 'savings_percent', 0, 0),
              ('economy_20', 'Экономия 20%', 'Сэкономьте 20% от планируемых расходов', 'trending_down', 20, 'economy_percent', 0, 0),
              ('month_budget', '30 дней учета', 'Ведите учет бюджета 30 дней подряд', 'event_available', 30, 'budget_days', 0, 0),
              ('big_purchase', 'Крупная покупка', 'Совершите покупку на сумму более 100000', 'stars', 100000, 'single_expense', 0, 0),
              ('millionaire', 'Миллионер', 'Накопите 1000000 на счету', 'diamond', 1000000, 'balance', 0, 0),
              ('finance_guru', 'Финансовый гуру', 'Получите все остальные достижения', 'workspace_premium', 13, 'total_achievements', 0, 0)
          ''');
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

    return List.generate(maps.length, (i) {
      return Loan(
        id: maps[i]['id'],
        amount: maps[i]['amount'],
        interestRate: maps[i]['interestRate'],
        months: maps[i]['months'],
        isAnnuity: maps[i]['isAnnuity'] == 1,
      );
    });
  }

  static Future<void> insertLoan(Loan loan) async {
    final db = await database;
    await db.insert(
      'loans',
      {
        'id': loan.id,
        'amount': loan.amount,
        'interestRate': loan.interestRate,
        'months': loan.months,
        'isAnnuity': loan.isAnnuity ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateLoan(Loan loan) async {
    final db = await database;
    await db.update(
      'loans',
      {
        'amount': loan.amount,
        'interestRate': loan.interestRate,
        'months': loan.months,
        'isAnnuity': loan.isAnnuity ? 1 : 0,
      },
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
        id: maps[i]['id'],
        name: maps[i]['name'],
        icon: maps[i]['icon'],
        color: maps[i]['color'],
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
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
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
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('achievements');

    return List.generate(maps.length, (i) {
      return Achievement.fromJson({
        'id': maps[i]['id'],
        'name': maps[i]['name'],
        'description': maps[i]['description'],
        'icon': maps[i]['icon'],
        'isUnlocked': maps[i]['isUnlocked'] == 1,
        'progress': maps[i]['progress'],
        'targetValue': maps[i]['targetValue'],
      });
    });
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
    await db.transaction((txn) async {
      await txn.delete('expenses');
      await txn.delete('loans');
      await txn.delete('categories');
      await txn.delete('achievements');
      await txn.delete('reminders');
    });
  }
}