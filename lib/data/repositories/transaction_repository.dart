import 'package:sqflite/sqflite.dart';

import '../../models/transaction_entity.dart';
import '../db/database_helper.dart';

class TransactionRepository {
  final DatabaseHelper _databaseHelper;

  TransactionRepository(this._databaseHelper);

  Future<int> createTransaction(TransactionEntity transaction) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'transactions',
      transaction.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionEntity>> getAllTransactions() async {
    final db = await _databaseHelper.database;
    final result = await db.query('transactions');
    return result.map((json) => TransactionEntity.fromJson(json)).toList();
  }

  Future<int> updateTransaction(TransactionEntity transaction) async {
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
