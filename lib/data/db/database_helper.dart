import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'budget_manager.db');

    // Uncomment to reset the database
    //await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
        is_income INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type INTEGER NOT NULL,
        amount REAL NOT NULL,
        category_id INTEGER,
        currency TEXT,
        date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
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

    // Pobranie danych
    final categories = await db.query('categories');
    final transactions = await db.query('transactions');

    final Map<String, dynamic> backupData = {
      'categories': categories,
      'transactions': transactions,
    };

    final jsonString = jsonEncode(backupData);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/backup.json');
    await file.writeAsString(jsonString);

    return file.path;
  }

  Future<void> importDatabase() async {
    final db = await database;

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/backup.json');
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
}
