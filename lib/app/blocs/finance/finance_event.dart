part of 'finance_bloc.dart';

abstract class FinanceEvent extends Equatable {
  const FinanceEvent();

  @override
  List<Object> get props => [];
}

class FetchFinances extends FinanceEvent {}

class AddFinance extends FinanceEvent {
  final Finance finance;

  const AddFinance(this.finance);

  @override
  List<Object> get props => [finance];
}
