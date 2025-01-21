import 'package:flutter/material.dart';

import '../../models/transaction.dart';

abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {
  final DateTimeRange? dateRange;

  LoadTransactions({this.dateRange});
}

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

class FilterTransactions extends TransactionEvent {
  final String? name;
  final int? categoryId;
  final double? amountMin;
  final double? amountMax;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  FilterTransactions({
    this.name,
    this.categoryId,
    this.amountMin,
    this.amountMax,
    this.dateFrom,
    this.dateTo,
  });
}
