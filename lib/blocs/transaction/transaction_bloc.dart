import 'dart:async';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_budget/blocs/currency_conversion/currency_conversion_bloc.dart';
import 'package:smart_budget/blocs/currency_conversion/currency_conversion_state.dart';
import 'package:smart_budget/blocs/transaction/transaction_event.dart';
import 'package:smart_budget/blocs/transaction/transaction_state.dart';

import '../../data/mappers/transaction_mapper.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../di/di.dart';
import '../../di/notifiers/currency_notifier.dart';
import '../../models/category.dart';
import '../../models/currency_rate.dart';
import '../category/category_bloc.dart';
import '../category/category_event.dart';
import 'package:provider/provider.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;
  final CurrencyConversionBloc currencyConversionBloc;
  final CurrencyNotifier currencyNotifier;

  StreamSubscription? _currencyRatesSubscription;
  VoidCallback? _currencyChangeListener;

  TransactionBloc(
      this.transactionRepository,
      this.categoryRepository,
      this.currencyConversionBloc,
      this.currencyNotifier,
      ) : super(TransactionsLoading()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);

    _currencyRatesSubscription = currencyConversionBloc.stream.listen((state) {
      if (state is CurrencyRatesLoaded) {
        add(LoadTransactions());
      }
    });

    _currencyChangeListener = () {
      add(LoadTransactions());
    };
    currencyNotifier.addListener(_currencyChangeListener!);
  }

  Future<void> _onLoadTransactions(
      LoadTransactions event, Emitter<TransactionState> emit) async {
    try {
      emit(TransactionsLoading());

      final transactions = await transactionRepository.getAllTransactions();
      final categories = await categoryRepository.getAllCategories();
      final rates = await currencyConversionBloc.repository.fetchCurrencyRates();
      final userCurrency = currencyNotifier.currency;

      final convertedTransactions = transactions.map((transaction) {
        final category = categories.firstWhere(
              (cat) => cat.id == transaction.categoryId,
          orElse: () => Category(
            id: null,
            name: 'Unknown',
            isIncome: false,
          ),
        );

        final baseToUsdRate = rates.firstWhere(
              (rate) => rate.code.toUpperCase() == transaction.currency.value.toUpperCase(),
          orElse: () => CurrencyRate(name: 'USD', code: 'USD', rate: 1.0),
        ).rate;

        final usdToUserCurrencyRate = rates.firstWhere(
              (rate) => rate.code.toUpperCase() == userCurrency.value.toUpperCase(),
          orElse: () => CurrencyRate(name: 'USD', code: 'USD', rate: 1.0),
        ).rate;

        final conversionRate = usdToUserCurrencyRate / baseToUsdRate;

        return TransactionMapper.mapFromEntity(
          transaction,
          conversionRate,
          category,
        );
      }).toList();

      emit(TransactionsLoaded(convertedTransactions));
      getIt<CategoryBloc>().add(LoadCategoriesWithSpentAmounts());
    } catch (e, stackTrace) {
      print('Error loading transactions: $e');
      print(stackTrace);
      emit(TransactionError('Failed to load transactions: $e'));
    }
  }

  Future<void> _onAddTransaction(
      AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      final transaction = TransactionMapper.toEntity(event.transaction);
      await transactionRepository.createTransaction(transaction);
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError('Failed to add transaction'));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransaction event, Emitter<TransactionState> emit) async {
    try {
      final transaction = TransactionMapper.toEntity(event.transaction);
      await transactionRepository.updateTransaction(transaction);
      add(LoadTransactions());
      getIt<CategoryBloc>().add(LoadCategoriesWithSpentAmounts());
    } catch (e) {
      emit(TransactionError('Failed to update transaction'));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransaction event, Emitter<TransactionState> emit) async {
    try {
      await transactionRepository.deleteTransaction(event.id);
      add(LoadTransactions());
      getIt<CategoryBloc>().add(LoadCategoriesWithSpentAmounts());
    } catch (e) {
      emit(TransactionError('Failed to delete transaction'));
    }
  }

  @override
  Future<void> close() {
    _currencyRatesSubscription?.cancel();
    if (_currencyChangeListener != null) {
      currencyNotifier.removeListener(_currencyChangeListener!);
    }
    return super.close();
  }
}
