import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/transaction_repository.dart';
import 'transaction_type_event.dart';
import 'transaction_type_state.dart';

class TransactionTypeBloc extends Bloc<TransactionTypeEvent, TransactionTypeState> {
  final TransactionRepository transactionRepository;

  TransactionTypeBloc(this.transactionRepository) : super(TransactionTypesLoading()) {
    on<LoadTransactionTypes>(_onLoadTransactionTypes);
    on<AddTransactionType>(_onAddTransactionType);
    on<UpdateTransactionType>(_onUpdateTransactionType);
    on<DeleteTransactionType>(_onDeleteTransactionType);
  }

  Future<void> _onLoadTransactionTypes(
      LoadTransactionTypes event, Emitter<TransactionTypeState> emit) async {
    try {
      emit(TransactionTypesLoading());
      final transactionTypes = await transactionRepository.getAllTransactionTypes();
      emit(TransactionTypesLoaded(transactionTypes));
    } catch (e) {
      emit(TransactionTypeError('Failed to load transaction types'));
    }
  }

  Future<void> _onAddTransactionType(
      AddTransactionType event, Emitter<TransactionTypeState> emit) async {
    try {
      await transactionRepository.createTransactionType(event.transactionType);
      final transactionTypes = await transactionRepository.getAllTransactionTypes();
      emit(TransactionTypesLoaded(transactionTypes));
    } catch (e) {
      emit(TransactionTypeError('Failed to add transaction type'));
    }
  }

  Future<void> _onUpdateTransactionType(
      UpdateTransactionType event, Emitter<TransactionTypeState> emit) async {
    try {
      await transactionRepository.updateTransactionType(event.transactionType);
      final transactionTypes = await transactionRepository.getAllTransactionTypes();
      emit(TransactionTypesLoaded(transactionTypes));
    } catch (e) {
      emit(TransactionTypeError('Failed to update transaction type'));
    }
  }

  Future<void> _onDeleteTransactionType(
      DeleteTransactionType event, Emitter<TransactionTypeState> emit) async {
    try {
      await transactionRepository.deleteTransactionType(event.id);
      final transactionTypes = await transactionRepository.getAllTransactionTypes();
      emit(TransactionTypesLoaded(transactionTypes));
    } catch (e) {
      emit(TransactionTypeError('Failed to delete transaction type'));
    }
  }
}
