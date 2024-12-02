import '../../models/transaction_type_model.dart';

abstract class TransactionTypeState {}

class TransactionTypesLoading extends TransactionTypeState {}

class TransactionTypesLoaded extends TransactionTypeState {
  final List<TransactionType> transactionTypes;
  TransactionTypesLoaded(this.transactionTypes);
}

class TransactionTypeError extends TransactionTypeState {
  final String message;
  TransactionTypeError(this.message);
}
