import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget/data/db/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper databaseHelper;

  setUp(() {
    databaseHelper = DatabaseHelper(factory: databaseFactoryFfi);
  });

  test('Database initializes successfully', () async {
    final db = await databaseHelper.database;
    expect(db.isOpen, true);
  });

  test('CRUD operations on categories', () async {
    final db = await databaseHelper.database;

    final id = await db.insert('categories', {
      'name': 'Test Category',
      'icon': null,
      'description': 'A test category',
      'budget_limit': 100.0,
      'is_income': 1,
    });
    expect(id, isNotNull);

    final result = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    expect(result.first['name'], 'Test Category');

    await db.update(
      'categories',
      {'budget_limit': 200.0},
      where: 'id = ?',
      whereArgs: [id],
    );
    final updated = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    expect(updated.first['budget_limit'], 200.0);

    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    final finalResult = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    expect(finalResult.isEmpty, true);
  });
}