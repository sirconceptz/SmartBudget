import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:smart_budget/blocs/category/category_bloc.dart';
import 'package:smart_budget/blocs/currency_conversion/currency_conversion_bloc.dart';
import 'package:smart_budget/blocs/transaction/transaction_bloc.dart';
import 'package:smart_budget/blocs/transaction/transaction_event.dart';
import 'package:smart_budget/blocs/transaction/transaction_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_budget/data/repositories/category_repository.dart';
import 'package:smart_budget/data/repositories/transaction_repository.dart';
import 'package:smart_budget/di/notifiers/currency_notifier.dart';
import 'package:smart_budget/utils/enums/currency.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}
class MockCategoryRepository extends Mock implements CategoryRepository {}
class MockCurrencyConversionBloc extends Mock implements CurrencyConversionBloc {}
class MockCurrencyNotifier extends Mock implements CurrencyNotifier {}

@GenerateMocks([TransactionRepository])
void main() {
  late TransactionBloc bloc;
  late MockTransactionRepository transactionRepository;
  late MockCategoryRepository categoryRepository;
  late MockCurrencyConversionBloc currencyConversionBloc;
  late MockCurrencyNotifier currencyNotifier;
  late MockCategoryRepository mockCategoryRepository;
  late CategoryBloc categoryBloc;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
  transactionRepository = MockTransactionRepository();
    categoryRepository = MockCategoryRepository();
    currencyConversionBloc = MockCurrencyConversionBloc();
    currencyNotifier = MockCurrencyNotifier();
    categoryBloc = CategoryBloc(
      mockCategoryRepository,
      MockCurrencyConversionBloc(),
      MockCurrencyNotifier(),
    );

    bloc = TransactionBloc(
      transactionRepository,
      categoryBloc,
      categoryRepository,
      currencyConversionBloc,
      currencyNotifier,
    );
  });

  tearDown(() {
    bloc.close();
  });

  blocTest<TransactionBloc, TransactionState>(
    'emits [TransactionsLoading, TransactionsLoaded] when LoadTransactions is added',
    build: () {
      when(() => transactionRepository.getAllTransactions())
          .thenAnswer((_) async => []);
      when(() => categoryRepository.getAllCategories())
          .thenAnswer((_) async => []);
      when(() => currencyConversionBloc.repository.fetchCurrencyRates())
          .thenAnswer((_) async => []);
      when(() => currencyNotifier.currency).thenReturn(Currency.usd);

      return bloc;
    },
    act: (bloc) => bloc.add(LoadTransactions()),
    expect: () => [
      isA<TransactionsLoading>(),
      isA<TransactionsLoaded>(),
    ],
  );

  blocTest<TransactionBloc, TransactionState>(
    'emits [TransactionError] when LoadTransactions fails',
    build: () {
      when(() => transactionRepository.getAllTransactions())
          .thenThrow(Exception('Failed to fetch transactions'));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadTransactions()),
    expect: () => [
      isA<TransactionsLoading>(),
      isA<TransactionError>(),
    ],
  );
}
