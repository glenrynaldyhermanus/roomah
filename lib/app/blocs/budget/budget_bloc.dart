import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/app/models/budget_item.dart';
import 'package:myapp/app/services/supabase_service.dart';

part 'budget_event.dart';
part 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  BudgetBloc() : super(BudgetInitial()) {
    on<FetchBudgets>(_onFetchBudgets);
    on<AddBudget>(_onAddBudget);
  }

  Future<void> _onFetchBudgets(
      FetchBudgets event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final response = await SupabaseService.client.from('budgets').select();
      final budgets = (response as List).map((json) => Budget.fromJson(json)).toList();
      emit(BudgetLoaded(budgets));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onAddBudget(AddBudget event, Emitter<BudgetState> emit) async {
    try {
      final response = await SupabaseService.client.from('budgets').insert({
        'name': event.name,
        'amount': event.amount,
        'start_date': event.startDate.toIso8601String(),
        'end_date': event.endDate.toIso8601String(),
      }).select();
      final newBudget = Budget.fromJson(response[0]);
      if (state is BudgetLoaded) {
        final updatedBudgets = List<Budget>.from((state as BudgetLoaded).budgets)
          ..add(newBudget);
        emit(BudgetLoaded(updatedBudgets));
      }
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }
}
