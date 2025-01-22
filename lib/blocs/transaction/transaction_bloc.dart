import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_budget/blocs/currency_conversion/currency_conversion_bloc.dart';
import 'package:smart_budget/blocs/currency_conversion/currency_conversion_state.dart';
import 'package:smart_budget/blocs/transaction/transaction_event.dart';
import 'package:smart_budget/blocs/transaction/transaction_state.dart';
import 'package:smart_budget/utils/my_logger.dart';

import '../../data/mappers/transaction_mapper.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../di/di.dart';
import '../../di/notifiers/currency_notifier.dart';
import '../../models/category.dart';
import '../category/category_bloc.dart';
import '../category/category_event.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;
  final CurrencyConversionBloc currencyConversionBloc;
  final CurrencyNotifier currencyNotifier;
  final CategoryBloc categoryBloc;

  StreamSubscription? _currencyRatesSubscription;
  VoidCallback? _currencyChangeListener;

  TransactionBloc(
    this.transactionRepository,
    this.categoryBloc,
    this.categoryRepository,
    this.currencyConversionBloc,
    this.currencyNotifier,
  ) : super(TransactionsLoading()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<FilterTransactions>(_onFilterTransactions);

    currencyConversionBloc.registerOnCurrencyRatesLoadedCallback(() {
      add(LoadTransactions());
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

      final categories = await categoryRepository.getAllCategories();
      final transactions =
          await transactionRepository.getAllTransactions(categories);

      final state = currencyConversionBloc.state;
      if (state is! CurrencyRatesLoaded) {
        throw Exception("Currency rates not loaded");
      }

      final rates = state.rates;
      final userCurrency = currencyNotifier.currency;

      final ratesMap = {
        for (var rate in rates) rate.code.toUpperCase(): rate.rate
      };

      const defaultRate = 1.0;

      final convertedTransactions = transactions.map((transaction) {
        final category = categories.firstWhere(
          (cat) => cat.id == transaction.category!.id,
          orElse: () => Category(
            id: null,
            name: 'Unknown',
            description: 'Unknown',
            isIncome: false,
            currency: userCurrency,
          ),
        );

        final baseToUsdRate =
            ratesMap[transaction.originalCurrency.value.toUpperCase()] ??
                defaultRate;
        final usdToUserCurrencyRate =
            ratesMap[userCurrency.value.toUpperCase()] ?? defaultRate;

        final conversionRate = usdToUserCurrencyRate / baseToUsdRate;

        return TransactionMapper.mapFromEntityAndConvert(
          TransactionMapper.toEntity(transaction),
          conversionRate,
          category,
        );
      }).toList();

      emit(TransactionsLoaded(convertedTransactions));

      final dateRange = event.dateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(Duration(days: 30)),
            end: DateTime.now(),
          );

      getIt<CategoryBloc>().add(LoadCategoriesWithSpentAmounts(dateRange));
    } catch (e) {
      MyLogger.write("Error loading transactions", e.toString());
      emit(TransactionError('Failed to load transactions: $e'));
    }
  }

  Future<void> _onAddTransaction(
      AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      await transactionRepository.createTransaction(event.transaction);
      add(LoadTransactions());
      final dateRange = DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 30)),
        end: DateTime.now(),
      );
      getIt<CategoryBloc>().add(LoadCategoriesWithSpentAmounts(dateRange));
    } catch (e) {
      emit(TransactionError('Failed to add transaction'));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransaction event, Emitter<TransactionState> emit) async {
    try {
      await transactionRepository.updateTransaction(event.transaction);
      add(LoadTransactions());
      final dateRange = DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 30)),
        end: DateTime.now(),
      );
      getIt<CategoryBloc>().add(LoadCategoriesWithSpentAmounts(dateRange));
    } catch (e) {
      emit(TransactionError('Failed to update transaction'));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransaction event, Emitter<TransactionState> emit) async {
    try {
      await transactionRepository.deleteTransaction(event.id);
      add(LoadTransactions());
      final dateRange = DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 30)),
        end: DateTime.now(),
      );
      getIt<CategoryBloc>().add(LoadCategoriesWithSpentAmounts(dateRange));
    } catch (e) {
      emit(TransactionError('Failed to delete transaction'));
    }
  }

  Future<void> _onFilterTransactions(
    FilterTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(TransactionsLoading());

      final categories = await categoryRepository.getAllCategories();

      final allTx = await transactionRepository.getAllTransactions(categories);

      final filtered = allTx.where((tx) {
        if (event.categoryId != null &&
            tx.category != null &&
            tx.category!.id != event.categoryId) {
          return false;
        }
        if (event.dateFrom != null && tx.date.isBefore(event.dateFrom!)) {
          return false;
        }
        if (event.dateTo != null && tx.date.isAfter(event.dateTo!)) {
          return false;
        }
        if (event.name != null && event.name!.isNotEmpty) {
          final desc = tx.description?.toLowerCase() ?? "";
          final filter = event.name!.toLowerCase();
          if (!desc.contains(filter)) {
            return false;
          }
        }
        // Kwota
        if (event.amountMin != null && tx.convertedAmount < event.amountMin!) {
          return false;
        }
        if (event.amountMax != null && tx.convertedAmount > event.amountMax!) {
          return false;
        }
        return true;
      }).toList();

      final currentState = currencyConversionBloc.state;
      if (currentState is! CurrencyRatesLoaded) {
        throw Exception("Currency rates not loaded");
      }
      final rates = currentState.rates;
      final userCurrency = currencyNotifier.currency;

      final ratesMap = {
        for (var rate in rates) rate.code.toUpperCase(): rate.rate
      };
      const defaultRate = 1.0;

      final convertedTransactions = filtered.map((transaction) {
        final category = categories.firstWhere(
          (cat) => cat.id == transaction.category!.id,
          orElse: () => Category(
            id: null,
            name: 'Unknown',
            description: 'Unknown',
            isIncome: false,
            currency: userCurrency,
          ),
        );

        final baseToUsdRate =
            ratesMap[transaction.originalCurrency.value.toUpperCase()] ??
                defaultRate;
        final usdToUserCurrencyRate =
            ratesMap[userCurrency.value.toUpperCase()] ?? defaultRate;

        final conversionRate = usdToUserCurrencyRate / baseToUsdRate;

        return TransactionMapper.mapFromEntityAndConvert(
          TransactionMapper.toEntity(transaction),
          conversionRate,
          category,
        );
      }).toList();

      emit(TransactionsLoaded(convertedTransactions));
    } catch (e) {
      emit(TransactionError('Failed to filter transactions: $e'));
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
