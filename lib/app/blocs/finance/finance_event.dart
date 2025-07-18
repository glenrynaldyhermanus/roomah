part of 'finance_bloc.dart';

abstract class FinanceEvent extends Equatable {
  const FinanceEvent();

  @override
  List<Object> get props => [];
}

class FetchTransactions extends FinanceEvent {}

class AddTransaction extends FinanceEvent {
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
