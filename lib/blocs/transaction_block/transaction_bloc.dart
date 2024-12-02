import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_budget/blocs/transaction_block/transaction_event.dart';
import 'package:smart_budget/blocs/transaction_block/transaction_state.dart';

import '../../data/repositories/transaction_repository.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;

  TransactionBloc(this.transactionRepository) : super(TransactionsLoading()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
      LoadTransactions event, Emitter<TransactionState> emit) async {
    try {
      emit(TransactionsLoading());
      final transactions = await transactionRepository.getAllTransactions();
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionError('Failed to load transactions'));
    }
  }

  Future<void> _onAddTransaction(
      AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      await transactionRepository.createTransaction(event.transaction);
      final transactions = await transactionRepository.getAllTransactions();
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionError('Failed to add transaction'));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransaction event, Emitter<TransactionState> emit) async {
    try {
      await transactionRepository.updateTransaction(event.transaction);
      final transactions = await transactionRepository.getAllTransactions();
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionError('Failed to update transaction'));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransaction event, Emitter<TransactionState> emit) async {
    try {
      await transactionRepository.deleteTransaction(event.id);
      final transactions = await transactionRepository.getAllTransactions();
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionError('Failed to delete transaction'));
    }
  }
}
