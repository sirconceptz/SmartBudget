import 'package:sqflite/sqflite.dart';

import '../../models/transaction.dart' as t;
import '../db/database_helper.dart';

class TransactionRepository {
  final DatabaseHelper _databaseHelper;

  TransactionRepository(this._databaseHelper);

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
}
