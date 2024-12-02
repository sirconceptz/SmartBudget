import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../../models/category.dart';

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
}
