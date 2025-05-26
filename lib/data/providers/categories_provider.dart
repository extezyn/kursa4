import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/database.dart';
import 'database_provider.dart';

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.categories).watch();
}); 