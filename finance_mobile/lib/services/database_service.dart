import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/loan.dart';

class DatabaseService {
  static Database? _db;

  static Future<void> initDB() async {
    if (_db != null) return;
    final path = join(await getDatabasesPath(), 'finance.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE expenses (
          id TEXT PRIMARY KEY,
          category TEXT,
          amount REAL,
          date TEXT
        );
      ''');
        db.execute('''
        CREATE TABLE loans (
          id TEXT PRIMARY KEY,
          amount REAL,
          interestRate REAL,
          months INTEGER,
          isAnnuity INTEGER
        );
      ''');
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
}
