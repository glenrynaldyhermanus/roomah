part of 'finance_bloc.dart';

abstract class FinanceState extends Equatable {
  const FinanceState();

  @override
  List<Object> get props => [];
}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {
  final List<Transaction> transactions;

  const FinanceLoaded(this.transactions);

  @override
  List<Object> get props => [transactions];
}

class FinanceError extends FinanceState {
  final String message;

  const FinanceError(this.message);

  @override
  List<Object> get props => [message];
}
