import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/blocs/transaction/transaction_event.dart';
import 'package:smart_budget/blocs/transaction/transaction_state.dart';

import '../../data/repositories/currency_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../models/currency_rate.dart';
import '../../models/transaction.dart';
import '../../utils/enums/currency.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;
  final CurrencyRepository currencyConversionRepository;
  final Currency userCurrency;

  TransactionBloc(this.transactionRepository, this.currencyConversionRepository,
      this.userCurrency)
      : super(TransactionsLoading()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
      LoadTransactions event, Emitter<TransactionState> emit) async {
    try {
      emit(TransactionsLoading());
      final prefs = await SharedPreferences.getInstance();
      final savedCurrency = prefs.getString('selected_currency') ?? 'usd';
      Currency baseCurrency = CurrencyExtension.fromString(savedCurrency);
      final transactions = await transactionRepository.getAllTransactions();
      final rates = await currencyConversionRepository
          .fetchCurrencyRates(baseCurrency.value);

      final rateList = rates.entries
          .map((entry) =>
              CurrencyRate(name: entry.key, code: entry.key, rate: entry.value))
          .toList();

      final convertedTransactions =
          _convertTransactionsToUserCurrency(transactions, rateList);

      emit(TransactionsLoaded(convertedTransactions));
    } catch (e) {
      emit(TransactionError('Failed to load transactions'));
    }
  }

  Future<void> _onAddTransaction(
      AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      await transactionRepository.createTransaction(event.transaction);
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError('Failed to add transaction'));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransaction event, Emitter<TransactionState> emit) async {
    try {
      await transactionRepository.updateTransaction(event.transaction);
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError('Failed to update transaction'));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransaction event, Emitter<TransactionState> emit) async {
    try {
      await transactionRepository.deleteTransaction(event.id);
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError('Failed to delete transaction'));
    }
  }

  List<Transaction> _convertTransactionsToUserCurrency(
      List<Transaction> transactions, List<CurrencyRate> rates) {
    final rateMap = {for (var rate in rates) rate.code: rate};

    return transactions.map((transaction) {
      if (transaction.currency == userCurrency) {
        return transaction;
      }

      final targetRate = rateMap[userCurrency.value]?.rate ?? 1.0;
      final sourceRate = rateMap[transaction.currency.value]?.rate ?? 1.0;

      final convertedAmount = transaction.amount * (targetRate / sourceRate);

      return transaction.copyWith(
        amount: convertedAmount,
        currency: userCurrency,
      );
    }).toList();
  }
}
