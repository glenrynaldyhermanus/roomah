import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/app/models/finance.dart';
import 'package:myapp/app/services/supabase_service.dart';

part 'finance_event.dart';
part 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final SupabaseService _supabaseService;

  FinanceBloc(this._supabaseService) : super(FinanceInitial()) {
    on<FetchFinances>(_onFetchFinances);
    on<AddFinance>(_onAddFinance);
  }

  Future<void> _onFetchFinances(
      FetchFinances event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    try {
      final finances = await _supabaseService.getFinances();
      emit(FinanceLoaded(finances));
    } catch (e) {
      String errorMessage = 'An error occurred while fetching finances.';
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Socket Exception') ||
          e.toString().contains('rrno = 7') ||
          e.toString().contains('no address associated with hostname')) {
        errorMessage = 'Network error: Unable to resolve hostname. Please check your internet connection.';
      }
      emit(FinanceError(errorMessage));
    }
  }

  Future<void> _onAddFinance(
      AddFinance event, Emitter<FinanceState> emit) async {
    final currentState = state;
    if (currentState is FinanceLoaded) {
      try {
        await _supabaseService.addFinance(event.finance);
        final finances = await _supabaseService.getFinances();
        emit(FinanceLoaded(finances));
      } catch (e) {
        String errorMessage = 'An error occurred while adding finance.';
        if (e.toString().contains('Failed host lookup') || 
            e.toString().contains('Socket Exception') ||
            e.toString().contains('rrno = 7') ||
            e.toString().contains('no address associated with hostname')) {
          errorMessage = 'Network error: Unable to resolve hostname. Please check your internet connection.';
        }
        emit(FinanceError(errorMessage));
      }
    }
  }
}
