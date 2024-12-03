import 'package:sqflite/sqflite.dart';

import '../../models/category.dart';
import '../db/database_helper.dart';

class CategoryRepository {
  final DatabaseHelper _databaseHelper;

  CategoryRepository(this._databaseHelper);

  Future<int> createCategory(Category category) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'categories',
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Category>> getAllCategories() async {
    final db = await _databaseHelper.database;
    final result = await db.query('categories');
    return result.map((json) => Category.fromJson(json)).toList();
  }

  Future<int> updateCategory(Category category) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'categories',
      category.toJson(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getSpentAmountForCategories() async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery('''
      SELECT categories.id AS category_id, categories.name, categories.budget_limit,
             SUM(transactions.amount) AS spent_amount
      FROM categories
      LEFT JOIN transactions ON categories.id = transactions.category_id
      GROUP BY categories.id
    ''');
    return result;
  }

  Future<void> createOrReplaceCategory(Category category) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'categories',
      {
        'id': category.id,
        'name': category.name,
        'icon': category.icon,
        'description': category.description,
        'is_income': category.isIncome ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
