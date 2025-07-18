part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class FetchTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final double amount;
  final String type;
  final String? description;
  final DateTime transactionDate;

  const AddTransaction({
    required this.amount,
    required this.type,
    this.description,
    required this.transactionDate,
  });

  @override
  List<Object> get props => [amount, type, transactionDate];
}
