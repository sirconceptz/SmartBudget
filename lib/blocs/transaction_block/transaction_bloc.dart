import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/transaction_repository.dart';
import '../../models/transaction_model.dart';

abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final Transaction transaction;

  AddTransaction(this.transaction);
}

class UpdateTransaction extends TransactionEvent {
  final Transaction transaction;

  UpdateTransaction(this.transaction);
}

class DeleteTransaction extends TransactionEvent {
  final int id;

  DeleteTransaction(this.id);
}

abstract class TransactionState {}

class TransactionsLoading extends TransactionState {}

class TransactionsLoaded extends TransactionState {
  final List<Transaction> transactions;

  TransactionsLoaded(this.transactions);
}

class TransactionError extends TransactionState {}

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;

  TransactionBloc(this.repository) : super(TransactionsLoading()) {
    on<LoadTransactions>((event, emit) async {
      try {
        emit(TransactionsLoading());
        final transactions = await repository.getAllTransactions();
        emit(TransactionsLoaded(transactions));
      } catch (_) {
        emit(TransactionError());
      }
    });

    on<AddTransaction>((event, emit) async {
      try {
        await repository.createTransaction(event.transaction);
        add(LoadTransactions());
      } catch (_) {
        emit(TransactionError());
      }
    });

    on<UpdateTransaction>((event, emit) async {
      try {
        await repository.updateTransaction(event.transaction);
        add(LoadTransactions());
      } catch (_) {
        emit(TransactionError());
      }
    });

    on<DeleteTransaction>((event, emit) async {
      try {
        await repository.deleteTransaction(event.id);
        add(LoadTransactions());
      } catch (_) {
        emit(TransactionError());
      }
    });
  }
}
