import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../../models/transaction_model.dart' as t;

class TransactionRepository {
  final DatabaseHelper _databaseHelper;

  TransactionRepository(this._databaseHelper);

  // Create a transaction
  Future<int> createTransaction(t.Transaction transaction) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'transactions',
      transaction.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read all transactions
  Future<List<t.Transaction>> getAllTransactions() async {
    final db = await _databaseHelper.database;
    final result = await db.query('transactions');

    return result.map((json) => t.Transaction.fromJson(json)).toList();
  }

  // Update a transaction
  Future<int> updateTransaction(t.Transaction transaction) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Delete a transaction
  Future<int> deleteTransaction(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
