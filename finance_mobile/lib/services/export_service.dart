import 'dart:io';
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

class ExportService {
  static final _dateFormat = DateFormat('dd.MM.yyyy');
  static final _numberFormat = NumberFormat('#,##0.00', 'ru_RU');

  static Future<void> exportData(List<Expense> expenses, CategoryProvider categoryProvider) async {
    final directory = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    
    // Создаем Excel файл
    final excelPath = await _createExcelFile(expenses, categoryProvider, directory, timestamp);
    
    // Создаем CSV файл
    final csvPath = await _createCSVFile(expenses, categoryProvider, directory, timestamp);

    // Делимся обоими файлами
    if (excelPath != null && csvPath != null) {
      await Share.shareXFiles(
        [XFile(excelPath), XFile(csvPath)],
        subject: 'Экспорт финансов',
      );
    }
  }

  static Future<String?> _createExcelFile(
    List<Expense> expenses,
    CategoryProvider categoryProvider,
    Directory directory,
    String timestamp,
  ) async {
    try {
      final excel = Excel.createExcel();
      final Sheet sheet = excel['Транзакции'];

      // Добавляем заголовки
      sheet.appendRow([
        'Дата',
        'Тип',
        'Категория',
        'Сумма',
        'Примечание',
      ]);

      // Стиль для заголовков
      var headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: '#CCCCCC',
        horizontalAlign: HorizontalAlign.Center,
      );

      // Применяем стиль к заголовкам
      for (var i = 0; i < 5; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerStyle;
      }

      // Добавляем данные
      for (var expense in expenses) {
        final categoryName = categoryProvider.getCategoryName(expense.category);
        sheet.appendRow([
          _dateFormat.format(expense.date),
          expense.isIncome ? 'Доход' : 'Расход',
          categoryName,
          _numberFormat.format(expense.amount),
          expense.note ?? '',
        ]);
      }

      // Автоматическая ширина столбцов
      for (var i = 0; i < 5; i++) {
        sheet.setColWidth(i, 20.0);
      }

      final filePath = '${directory.path}/finance_export_$timestamp.xlsx';
      final List<int>? fileBytes = excel.save();
      
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        return filePath;
      }
    } catch (e) {
      print('Ошибка при создании Excel файла: $e');
    }
    return null;
  }

  static Future<String?> _createCSVFile(
    List<Expense> expenses,
    CategoryProvider categoryProvider,
    Directory directory,
    String timestamp,
  ) async {
    try {
      final filePath = '${directory.path}/finance_export_$timestamp.csv';
      final file = File(filePath);
      final sink = file.openWrite(encoding: utf8);

      // Добавляем BOM для корректного отображения кириллицы
      sink.add([0xEF, 0xBB, 0xBF]);

      // Записываем заголовки
      sink.writeln('Дата,Тип,Категория,Сумма,Примечание');

      // Записываем данные
      for (var expense in expenses) {
        final categoryName = categoryProvider.getCategoryName(expense.category);
        final formattedNote = expense.note?.replaceAll('"', '""') ?? '';
        final formattedCategory = categoryName.replaceAll('"', '""');
        
        sink.writeln(
          '"${_dateFormat.format(expense.date)}",' +
          '"${expense.isIncome ? 'Доход' : 'Расход'}",' +
          '"$formattedCategory",' +
          '"${_numberFormat.format(expense.amount)}",' +
          '"$formattedNote"'
        );
      }

      await sink.flush();
      await sink.close();
      return filePath;
    } catch (e) {
      print('Ошибка при создании CSV файла: $e');
    }
    return null;
  }
} 