import 'package:smart_budget/data/mappers/transaction_mapper.dart';
import 'package:smart_budget/utils/custom_date_time_range.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/category.dart';
import '../../models/transaction.dart' as t;
import '../../models/transaction_entity.dart';
import '../db/database_helper.dart';

class TransactionRepository {
  final DatabaseHelper _databaseHelper;

  TransactionRepository(this._databaseHelper);

  Future<int> createTransaction(t.Transaction transaction) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'transactions',
      TransactionMapper.toEntity(transaction).toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<t.Transaction>> getAllTransactions(
      List<Category> categories) async {
    final db = await _databaseHelper.database;
    final result = await db.query('transactions');
    return result
        .map((json) => TransactionMapper.mapFromEntity(
            TransactionEntity.fromJson(json), categories))
        .toList();
  }

  Future<int> updateTransaction(t.Transaction transaction) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'transactions',
      TransactionMapper.toEntity(transaction).toJson(),
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

  Future<List<t.Transaction>> getTransactionsByCustomMonth(
      DateTime selectedMonth,
      int firstDayOfMonth,
      List<Category> categories,
      ) async {
    final db = await _databaseHelper.database;

    final customRange = CustomDateTimeRange.getCustomMonthRange(selectedMonth, firstDayOfMonth);

    final startIso = customRange.start.toIso8601String();
    final endIso = customRange.end.toIso8601String();

    final result = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startIso, endIso],
    );

    return result
        .map(
          (map) => TransactionMapper.mapFromEntity(
        TransactionEntity.fromJson(map),
        categories,
      ),
    )
        .toList();
  }

}
