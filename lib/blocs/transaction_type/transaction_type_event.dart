import '../../models/transaction_type_model.dart';

abstract class TransactionTypeEvent {}

class LoadTransactionTypes extends TransactionTypeEvent {}

class AddTransactionType extends TransactionTypeEvent {
  final TransactionType transactionType;
  AddTransactionType(this.transactionType);
}

class UpdateTransactionType extends TransactionTypeEvent {
  final TransactionType transactionType;
  UpdateTransactionType(this.transactionType);
}

class DeleteTransactionType extends TransactionTypeEvent {
  final int id;
  DeleteTransactionType(this.id);
}
