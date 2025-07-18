import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/app/models/transaction.dart';
import 'package:myapp/app/services/supabase_service.dart';

part 'finance_event.dart';
part 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final SupabaseService _supabaseService;

  FinanceBloc(this._supabaseService) : super(FinanceInitial()) {
    on<FetchTransactions>(_onFetchTransactions);
    on<AddTransaction>(_onAddTransaction);
  }

  Future<void> _onFetchTransactions(
      FetchTransactions event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    try {
      final transactions = await _supabaseService.getTransactions();
      emit(FinanceLoaded(transactions));
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
      AddTransaction event, Emitter<FinanceState> emit) async {
    final currentState = state;
    if (currentState is FinanceLoaded) {
      try {
        await _supabaseService.addTransaction(event.transaction);
        final transactions = await _supabaseService.getTransactions();
        emit(FinanceLoaded(transactions));
      } catch (e) {
        emit(FinanceError(e.toString()));
      }
    }
  }
}
