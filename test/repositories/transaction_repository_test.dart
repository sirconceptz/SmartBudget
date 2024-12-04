// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:smart_budget/data/repositories/transaction_repository.dart';
// import 'package:smart_budget/utils/enums/currency.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:smart_budget/models/transaction.dart' as t;
// import 'database_helper.mocks.dart';
//
// @GenerateMocks([TransactionRepository])
// void main() {
//   late MockDatabaseHelper mockDatabaseHelper;
//   late MockDatabase mockDatabase;
//   late TransactionRepository transactionRepository;
//
//   setUp(() {
//     mockDatabaseHelper = MockDatabaseHelper();
//     mockDatabase = MockDatabase();
//     transactionRepository = TransactionRepository(mockDatabaseHelper);
//
//     when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
//   });
//
//   group('TransactionRepository', () {
//     test('createTransaction adds a new transaction to the database', () async {
//       final db = MockDatabase();
//       when(mockDatabaseHelper.database).thenAnswer((_) async => db);
//
//       final transaction = t.Transaction(
//         type: 1,
//         amount: 100.0,
//         date: DateTime.now(),
//         currency: Currency.pln
//       );
//
//       when(db.insert(
//         'transactions',
//         transaction.toJson(),
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       )).thenAnswer((_) async => 1);
//
//       final result = await transactionRepository.createTransaction(transaction);
//
//       expect(result, 1);
//       when(db.insert(
//         'transactions',
//         transaction.toJson(),
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       )).thenAnswer((_) async => 1);
//     });
//
//     test('getAllTransactions retrieves all transactions', () async {
//       final mockData = [
//         {
//           'id': 1,
//           'type': 1,
//           'amount': 50.0,
//           'date': DateTime.now().toIso8601String(),
//         },
//         {
//           'id': 2,
//           'type': 2,
//           'amount': -30.0,
//           'date': DateTime.now().toIso8601String(),
//         },
//       ];
//
//       when(mockDatabase.query('transactions')).thenAnswer((_) async => mockData);
//
//       final result = await transactionRepository.getAllTransactions();
//
//       expect(result.length, 2);
//       expect(result.first.id, 1);
//       expect(result.last.amount, -30.0);
//       verify(mockDatabase.query('transactions')).called(1);
//     });
//   });
// }
