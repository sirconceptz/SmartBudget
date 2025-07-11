import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final bool inMemory;
  final DatabaseFactory _databaseFactory;
  Database? _database;

  DatabaseHelper({
    required DatabaseFactory databaseFactory,
    this.inMemory = false,
  }) : _databaseFactory = databaseFactory;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> _initDatabase() async {
    String path;
    if (inMemory) {
      path = inMemoryDatabasePath; // ':memory:'
    } else {
      final dbPath = await _databaseFactory.getDatabasesPath();
      path = join(dbPath, 'budget_manager.db');
    }

    return await _databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon INTEGER,
        description TEXT,
        budget_limit REAL,
        currency TEXT,
        is_income INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        isExpense INTEGER NOT NULL,
        amount REAL NOT NULL,
        category_id INTEGER,
        currency TEXT,
        date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        description TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
    CREATE TABLE recurring_transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      isExpense INTEGER NOT NULL,
      amount REAL NOT NULL,
      category_id INTEGER,
      currency TEXT,
      start_date TIMESTAMP NOT NULL,
      repeat_interval TEXT NOT NULL, -- daily, weekly, monthly, yearly
      repeat_count INTEGER, -- null for unlimited, otherwise stops after n times
      description TEXT,
      FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
    )
  ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades if needed
  }

  Future<String> exportDatabase() async {
    final db = await database;

    final categories = await db.query('categories');
    final transactions = await db.query('transactions');

    final Map<String, dynamic> backupData = {
      'categories': categories,
      'transactions': transactions,
    };

    final jsonString = jsonEncode(backupData);

    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/backup.json');
    await file.writeAsString(jsonString);

    return file.path;
  }

  Future<void> importDatabase() async {
    final db = await database;

    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/backup.json');
    final jsonString = await file.readAsString();
    final Map<String, dynamic> backupData = jsonDecode(jsonString);

    final categories = backupData['categories'] as List<dynamic>;
    final transactions = backupData['transactions'] as List<dynamic>;

    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('categories');

      for (final category in categories) {
        await txn.insert('categories', Map<String, dynamic>.from(category));
      }

      for (final transaction in transactions) {
        await txn.insert(
            'transactions', Map<String, dynamic>.from(transaction));
      }
    });
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await database;
    return db.query(table);
  }
}
