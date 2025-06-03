import 'dart:io';
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';

class ExportService {
  static final _dateFormat = DateFormat('dd.MM.yyyy');

  static Future<void> exportToExcel(List<Expense> expenses, List<CategoryModel> categories) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Расходы'];

      // Добавляем заголовки
      sheet.appendRow([
        'Дата',
        'Категория',
        'Сумма',
        'Тип',
        'Примечание',
      ]);

      // Добавляем данные
      for (var expense in expenses) {
        final category = categories.firstWhere(
          (c) => c.id == expense.category,
          orElse: () => CategoryModel(
            id: '',
            name: 'Неизвестная категория',
            icon: '',
            color: '#000000',
          ),
        );

        sheet.appendRow([
          _dateFormat.format(expense.date),
          category.name,
          expense.amount.toString(),
          expense.isIncome ? 'Доход' : 'Расход',
          expense.note ?? '',
        ]);
      }

      // Получаем путь к временной директории
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/expenses.xlsx';

      // Сохраняем файл
      final bytes = excel.encode()!;
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      // Делимся файлом
      await Share.shareFiles(
        [filePath],
        text: 'Экспорт расходов',
        subject: 'Экспорт расходов из приложения',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> exportToCSV(List<Expense> expenses, List<CategoryModel> categories) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/expenses.csv';
      final file = File(filePath);

      // Создаем CSV с кодировкой UTF-8
      final sink = file.openWrite(encoding: utf8);

      // Добавляем BOM вручную
      sink.add([0xEF, 0xBB, 0xBF]);

      // Записываем заголовки
      sink.writeln('Дата,Категория,Сумма,Тип,Примечание');

      // Записываем данные
      for (var expense in expenses) {
        final category = categories.firstWhere(
          (c) => c.id == expense.category,
          orElse: () => CategoryModel(
            id: '',
            name: 'Неизвестная категория',
            icon: '',
            color: '#000000',
          ),
        );

        // Экранируем запятые и кавычки в значениях
        final formattedNote = expense.note?.replaceAll('"', '""') ?? '';
        final formattedCategory = category.name.replaceAll('"', '""');
        final formattedDate = _dateFormat.format(expense.date);
        final formattedAmount = expense.amount.toStringAsFixed(2).replaceAll('.', ',');

        sink.writeln(
          '"$formattedDate","$formattedCategory","$formattedAmount","${expense.isIncome ? 'Доход' : 'Расход'}","$formattedNote"'
        );
      }

      await sink.flush();
      await sink.close();

      // Делимся файлом
      await Share.shareFiles(
        [filePath],
        text: 'Экспорт расходов',
        subject: 'Экспорт расходов из приложения',
      );
    } catch (e) {
      rethrow;
    }
  }
} 