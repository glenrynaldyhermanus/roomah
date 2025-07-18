part of 'budget_bloc.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object> get props => [];
}

class FetchBudgets extends BudgetEvent {}

class AddBudget extends BudgetEvent {
  final String name;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;

  const AddBudget({
    required this.name,
    required this.amount,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [name, amount, startDate, endDate];
}
