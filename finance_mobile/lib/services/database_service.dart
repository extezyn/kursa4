import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/loan.dart';
import '../models/category.dart';
import '../models/achievement.dart';
import '../models/reminder.dart';

class DatabaseService {
  static Database? _db;

  static Future<void> initDB() async {
    if (_db != null) return;
    final path = join(await getDatabasesPath(), 'finance.db');
    _db = await openDatabase(
      path,
      version: 6,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses (
            id TEXT PRIMARY KEY,
            amount REAL,
            date TEXT,
            category TEXT,
            isIncome INTEGER DEFAULT 0,
            note TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE loans (
            id TEXT PRIMARY KEY,
            amount REAL,
            interestRate REAL,
            months INTEGER,
            isAnnuity INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT,
            color TEXT,
            isIncome INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE achievements (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            icon TEXT,
            isUnlocked INTEGER DEFAULT 0,
            progress REAL DEFAULT 0.0,
            targetValue REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE reminders (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            message TEXT,
            dateTime TEXT NOT NULL,
            isActive INTEGER DEFAULT 1
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE expenses ADD COLUMN isIncome INTEGER DEFAULT 0');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE expenses ADD COLUMN note TEXT');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS categories (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              icon TEXT,
              color TEXT
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE categories ADD COLUMN isIncome INTEGER DEFAULT 0');
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS achievements (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              description TEXT,
              icon TEXT,
              isUnlocked INTEGER DEFAULT 0,
              progress REAL DEFAULT 0.0,
              targetValue REAL
            )
          ''');
        }
        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS reminders (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              message TEXT,
              dateTime TEXT NOT NULL,
              isActive INTEGER DEFAULT 1
            )
          ''');
        }
      },
    );
  }

  static Future<void> insertExpense(Expense expense) async {
    await _db!.insert('expenses', expense.toMap());
  }

  static Future<List<Expense>> getExpenses() async {
    final maps = await _db!.query('expenses');
    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  static Future<void> deleteExpense(String id) async {
    await _db!.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateExpense(Expense expense) async {
    await _db!.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  static Future<void> insertLoan(Loan loan) async {
    await _db!.insert('loans', {
      'id': loan.id,
      'amount': loan.amount,
      'interestRate': loan.interestRate,
      'months': loan.months,
      'isAnnuity': loan.isAnnuity ? 1 : 0,
    });
  }

  static Future<List<Loan>> getLoans() async {
    final maps = await _db!.query('loans');
    return maps
        .map(
          (e) => Loan(
            id: e['id'] as String,
            amount: e['amount'] as double,
            interestRate: e['interestRate'] as double,
            months: e['months'] as int,
            isAnnuity: (e['isAnnuity'] as int) == 1,
          ),
        )
        .toList();
  }

  static Future<void> insertCategory(CategoryModel category) async {
    await _db!.insert('categories', category.toMap());
  }

  static Future<List<CategoryModel>> getCategories() async {
    final maps = await _db!.query('categories');
    return maps.map((e) => CategoryModel.fromMap(e)).toList();
  }

  static Future<void> updateCategory(CategoryModel category) async {
    await _db!.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  static Future<void> deleteCategory(String id) async {
    await _db!.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> insertAchievement(Achievement achievement) async {
    await _db!.insert('achievements', {
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
    final maps = await _db!.query('achievements');
    return maps.map((e) => Achievement.fromJson({
      'id': e['id'] as String,
      'name': e['name'] as String,
      'description': e['description'] as String,
      'icon': e['icon'] as String,
      'isUnlocked': (e['isUnlocked'] as int) == 1,
      'progress': e['progress'] as double,
      'targetValue': e['targetValue'] as double,
    })).toList();
  }

  static Future<void> updateAchievement(Achievement achievement) async {
    await _db!.update(
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
    await _db!.insert('reminders', reminder.toMap());
  }

  static Future<List<Reminder>> getReminders() async {
    final maps = await _db!.query('reminders');
    return maps.map((e) => Reminder.fromMap(e)).toList();
  }

  static Future<void> updateReminder(Reminder reminder) async {
    await _db!.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  static Future<void> deleteReminder(String id) async {
    await _db!.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearAllData() async {
    await _db!.transaction((txn) async {
      await txn.delete('expenses');
      await txn.delete('loans');
      await txn.delete('categories');
      await txn.delete('achievements');
      await txn.delete('reminders');
    });
  }
}
