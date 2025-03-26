import 'package:sqflite/sqflite.dart';

import '../../models/recurring_transaction.dart';
import '../db/database_helper.dart';
import '../mappers/recurring_transaction_mapper.dart';

class RecurringTransactionRepository {
  final DatabaseHelper _databaseHelper;

  RecurringTransactionRepository(this._databaseHelper);

  Future<List<RecurringTransaction>> getAllRecurringTransactions() async {
    final db = await _databaseHelper.database;
    final result = await db.query('recurring_transactions');
    return result
        .map((json) => RecurringTransactionMapper.fromEntity(json))
        .toList();
  }

  Future<int> addRecurringTransaction(RecurringTransaction transaction) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'recurring_transactions',
      RecurringTransactionMapper.toEntity(transaction),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateRecurringTransaction(
      RecurringTransaction transaction) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'recurring_transactions',
      RecurringTransactionMapper.toEntity(transaction),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteRecurringTransaction(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
