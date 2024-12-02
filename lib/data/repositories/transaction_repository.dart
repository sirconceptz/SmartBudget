import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../../models/transaction_model.dart' as t;
import '../../models/transaction_type_model.dart';
import '../../models/category_model.dart';

class TransactionRepository {
  final DatabaseHelper _databaseHelper;

  TransactionRepository(this._databaseHelper);

  // Transactions
  Future<int> createTransaction(t.Transaction transaction) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'transactions',
      transaction.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<t.Transaction>> getAllTransactions() async {
    final db = await _databaseHelper.database;
    final result = await db.query('transactions');
    return result.map((json) => t.Transaction.fromJson(json)).toList();
  }

  Future<int> updateTransaction(t.Transaction transaction) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Categories
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

  // Transaction Types
  Future<int> createTransactionType(TransactionType transactionType) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'transaction_types',
      transactionType.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionType>> getAllTransactionTypes() async {
    final db = await _databaseHelper.database;
    final result = await db.query('transaction_types');
    return result.map((json) => TransactionType.fromJson(json)).toList();
  }

  Future<int> updateTransactionType(TransactionType transactionType) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'transaction_types',
      transactionType.toJson(),
      where: 'id = ?',
      whereArgs: [transactionType.id],
    );
  }

  Future<int> deleteTransactionType(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'transaction_types',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
