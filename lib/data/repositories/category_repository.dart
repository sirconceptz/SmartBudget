import 'package:smart_budget/data/mappers/category_mapper.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/category.dart';
import '../../models/transaction_entity.dart';
import '../db/database_helper.dart';

class CategoryRepository {
  final DatabaseHelper _databaseHelper;

  CategoryRepository(this._databaseHelper);

  Future<List<Category>> getAllCategories() async {
    final db = await _databaseHelper.database;
    final result = await db.query('categories', orderBy: 'name');
    return result.map((json) => Category.fromJson(json)).toList();
  }

  Future<int> updateCategory(Category category) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'categories',
      CategoryMapper.toEntity(category).toJson(),
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

  Future<void> createOrReplaceCategory(Category category) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'categories',
      CategoryMapper.toEntity(category).toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Category>> getCategoriesWithTransactions() async {
    final db = await _databaseHelper.database;

    final categoriesResult = await db.query('categories');

    final categories =
        await Future.wait(categoriesResult.map((categoryJson) async {
      final transactionsResult = await db.query(
        'transactions',
        where: 'category_id = ?',
        whereArgs: [categoryJson['id']],
      );

      final transactions = transactionsResult
          .map((transactionJson) => TransactionEntity.fromJson(transactionJson))
          .toList();

      return Category.fromJson(categoryJson)..transactions = transactions;
    }).toList());

    return categories;
  }
}
