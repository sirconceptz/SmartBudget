import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_budget/blocs/transaction/transaction_bloc.dart';
import 'package:smart_budget/blocs/transaction/transaction_event.dart';
import 'package:smart_budget/blocs/transaction/transaction_state.dart';
import 'package:smart_budget/blocs/currency_conversion/currency_conversion_bloc.dart';
import 'package:smart_budget/blocs/currency_conversion/currency_conversion_state.dart';
import 'package:smart_budget/data/repositories/recurring_transactions_repository.dart';
import 'package:smart_budget/data/repositories/transaction_repository.dart';
import 'package:smart_budget/data/repositories/category_repository.dart';
import 'package:smart_budget/di/notifiers/currency_notifier.dart';
import 'package:smart_budget/models/currency_rate.dart';
import 'package:smart_budget/models/category.dart';
import 'package:smart_budget/models/transaction.dart';
import 'package:smart_budget/utils/enums/currency.dart';
import 'package:smart_budget/di/di.dart';
import 'package:smart_budget/blocs/category/category_bloc.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockRecurringTransactionRepository extends Mock implements RecurringTransactionRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockCurrencyConversionBloc extends Mock
    implements CurrencyConversionBloc {}

class MockCurrencyNotifier extends Mock implements CurrencyNotifier {}

class MockCategoryBloc extends Mock implements CategoryBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TransactionBloc transactionBloc;
  late MockTransactionRepository mockTransactionRepository;
  late MockRecurringTransactionRepository mockRecurringTransactionRepository;
  late MockCategoryRepository mockCategoryRepository;
  late MockCurrencyConversionBloc mockCurrencyConversionBloc;
  late MockCurrencyNotifier mockCurrencyNotifier;
  late MockCategoryBloc mockCategoryBloc;

  final userCurrency = Currency.usd;
  final testCategory = Category(
    id: 1,
    name: 'Test',
    description: 'Test category',
    isIncome: false,
    currency: userCurrency,
  );
  final testCategories = [testCategory];

  final testTransaction = Transaction(
    id: 1,
    date: DateTime(2023, 11, 20),
    isExpense: 1,
    originalAmount: 100,
    convertedAmount: 100,
    category: testCategory,
    description: "Test transaction",
    originalCurrency: userCurrency,
  );
  final testTransactions = [testTransaction];

  final testRates = [
    CurrencyRate(code: 'USD', name: 'US Dollar', rate: 1.0),
    CurrencyRate(code: 'EUR', name: 'Euro', rate: 0.85),
  ];

  setUpAll(() {
    registerFallbackValue(Transaction(
      id: 0,
      date: DateTime.now(),
      isExpense: 1,
      originalAmount: 0,
      convertedAmount: 0,
      category: testCategory,
      description: "",
      originalCurrency: userCurrency,
    ));
  });

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    mockRecurringTransactionRepository = MockRecurringTransactionRepository();
    mockCategoryRepository = MockCategoryRepository();
    mockCurrencyConversionBloc = MockCurrencyConversionBloc();
    mockCurrencyNotifier = MockCurrencyNotifier();
    mockCategoryBloc = MockCategoryBloc();

    if (getIt.isRegistered<CategoryBloc>()) {
      getIt.unregister<CategoryBloc>();
    }
    getIt.registerSingleton<CategoryBloc>(mockCategoryBloc);

    when(() => mockCurrencyConversionBloc.state)
        .thenReturn(CurrencyRatesLoaded(testRates));

    when(() => mockCurrencyNotifier.currency).thenReturn(userCurrency);

    transactionBloc = TransactionBloc(
      mockTransactionRepository,
      mockRecurringTransactionRepository,
      mockCategoryBloc,
      mockCategoryRepository,
      mockCurrencyConversionBloc,
      mockCurrencyNotifier,
    );
  });

  tearDown(() {
    transactionBloc.close();
  });

  group('TransactionBloc', () {
    blocTest<TransactionBloc, TransactionState>(
      'Emits TransactionsLoading followed by TransactionsLoaded when a LoadTransactions event is triggered and everything is working correctly',
      build: () {
        when(() => mockCategoryRepository.getAllCategories())
            .thenAnswer((_) async => testCategories);
        when(() => mockTransactionRepository.getAllTransactions(testCategories))
            .thenAnswer((_) async => testTransactions);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(LoadTransactions()),
      expect: () => [
        isA<TransactionsLoading>(),
        isA<TransactionsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockCategoryRepository.getAllCategories()).called(1);
        verify(() =>
                mockTransactionRepository.getAllTransactions(testCategories))
            .called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionsLoading, TransactionsLoaded] after sending AddTransaction if repository.createTransaction succeeds',
      build: () {
        when(() => mockTransactionRepository.createTransaction(any()))
            .thenAnswer((_) async => 1);
        when(() => mockCategoryRepository.getAllCategories())
            .thenAnswer((_) async => testCategories);
        when(() => mockTransactionRepository.getAllTransactions(testCategories))
            .thenAnswer((_) async => testTransactions);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(AddTransaction(testTransaction)),
      expect: () => [
        isA<TransactionsLoading>(),
        isA<TransactionsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockTransactionRepository.createTransaction(testTransaction)).called(1);
        verify(() => mockCategoryRepository.getAllCategories()).called(1);
        verify(() => mockTransactionRepository.getAllTransactions(testCategories)).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionsLoading, TransactionsLoaded] after sending UpdateTransaction if repository.updateTransaction succeeds',
      build: () {
        when(() => mockTransactionRepository.updateTransaction(any()))
            .thenAnswer((_) async => 1);
        when(() => mockCategoryRepository.getAllCategories())
            .thenAnswer((_) async => testCategories);
        when(() => mockTransactionRepository.getAllTransactions(testCategories))
            .thenAnswer((_) async => testTransactions);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(UpdateTransaction(testTransaction)),
      expect: () => [
        isA<TransactionsLoading>(),
        isA<TransactionsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockTransactionRepository.updateTransaction(testTransaction)).called(1);
        verify(() => mockCategoryRepository.getAllCategories()).called(1);
        verify(() => mockTransactionRepository.getAllTransactions(testCategories)).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionsLoading, TransactionsLoaded] after sending DeleteTransaction if repository.deleteTransaction succeeds',
      build: () {
        when(() => mockTransactionRepository.deleteTransaction(any()))
            .thenAnswer((_) async => 1);
        when(() => mockCategoryRepository.getAllCategories())
            .thenAnswer((_) async => testCategories);
        when(() => mockTransactionRepository.getAllTransactions(testCategories))
            .thenAnswer((_) async => testTransactions);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(DeleteTransaction(testTransaction.id!)),
      expect: () => [
        isA<TransactionsLoading>(),
        isA<TransactionsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockTransactionRepository.deleteTransaction(testTransaction.id!)).called(1);
        verify(() => mockCategoryRepository.getAllCategories()).called(1);
        verify(() => mockTransactionRepository.getAllTransactions(testCategories)).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionsLoading, TransactionsLoaded] after sending FilterTransactions if filtering succeeds',
      build: () {
        when(() => mockCategoryRepository.getAllCategories())
            .thenAnswer((_) async => testCategories);
        when(() => mockTransactionRepository.getAllTransactions(testCategories))
            .thenAnswer((_) async => testTransactions);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(FilterTransactions(
        categoryId: testCategory.id,
        dateFrom: DateTime(2023, 11, 1),
        dateTo: DateTime(2023, 11, 30),
        name: 'Test',
        amountMin: 50,
        amountMax: 150,
      )),
      expect: () => [
        isA<TransactionsLoading>(),
        isA<TransactionsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockCategoryRepository.getAllCategories()).called(1);
        verify(() => mockTransactionRepository.getAllTransactions(testCategories)).called(1);
      },
    );
  });
}
