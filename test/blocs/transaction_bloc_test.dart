// import 'package:bloc_test/bloc_test.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:smart_budget/blocs/transaction_block/transaction_bloc.dart';
// import 'package:smart_budget/blocs/transaction_block/transaction_state.dart';
// import 'package:smart_budget/models/transaction_model.dart';
//
// import '../repositories/transaction_repository_test.mocks.dart';
//
// void main() {
//   late MockTransactionRepository mockTransactionRepository;
//   late TransactionBloc transactionBloc;
//
//   setUp(() {
//     mockTransactionRepository = MockTransactionRepository();
//     transactionBloc = TransactionBloc(mockTransactionRepository);
//   });
//
//   group('TransactionBloc', () {
//     blocTest<TransactionBloc, TransactionState>(
//       'emits [TransactionsLoading, TransactionsLoaded] when LoadTransactions is added',
//       build: () {
//         when(mockTransactionRepository.getAllTransactions())
//             .thenAnswer((_) async => [
//           Transaction(id: 1, type: 1, amount: 50.0, date: DateTime.now()),
//           Transaction(id: 2, type: 2, amount: -30.0, date: DateTime.now()),
//         ]);
//         return TransactionBloc(mockTransactionRepository);
//       },
//       act: (bloc) => bloc.add(LoadTransactions()),
//       expect: () => [
//         TransactionsLoading(),
//         TransactionsLoaded([
//           Transaction(id: 1, type: 1, amount: 50.0, date: DateTime.now()),
//           Transaction(id: 2, type: 2, amount: -30.0, date: DateTime.now()),
//         ])
//       ],
//     );
//
//     blocTest<TransactionBloc, TransactionState>(
//       'emits [TransactionsLoading, TransactionError] when LoadTransactions fails',
//       build: () {
//         when(mockTransactionRepository.getAllTransactions())
//             .thenThrow(Exception());
//         return TransactionBloc(mockTransactionRepository);
//       },
//       act: (bloc) => bloc.add(LoadTransactions()),
//       expect: () => [
//         TransactionsLoading(),
//         TransactionError(),
//       ],
//     );
//
//     blocTest<TransactionBloc, TransactionState>(
//       'calls createTransaction and reloads transactions when AddTransaction is added',
//       build: () {
//         when(mockTransactionRepository.createTransaction(any))
//             .thenAnswer((_) async => 1);
//         when(mockTransactionRepository.getAllTransactions())
//             .thenAnswer((_) async => []);
//         return transactionBloc;
//       },
//       act: (bloc) => bloc.add(AddTransaction(Transaction(
//           type: 1, amount: 50.0, date: DateTime.now()))),
//       expect: () => [
//         TransactionsLoading(),
//         isA<TransactionsLoaded>(),
//       ],
//       verify: (_) {
//         verify(mockTransactionRepository.createTransaction(any)).called(1);
//         verify(mockTransactionRepository.getAllTransactions()).called(1);
//       },
//     );
//   });
// }
