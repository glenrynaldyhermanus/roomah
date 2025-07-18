import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/app/models/transaction.dart';
import 'package:myapp/app/services/supabase_service.dart';

part 'finance_event.dart';
part 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  FinanceBloc() : super(FinanceInitial()) {
    on<FetchTransactions>(_onFetchTransactions);
    on<AddTransaction>(_onAddTransaction);
  }

  Future<void> _onFetchTransactions(
      FetchTransactions event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    try {
      final response = await SupabaseService.client.from('finances').select();
      final transactions =
          (response as List).map((json) => Transaction.fromJson(json)).toList();
      emit(FinanceLoaded(transactions));
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
      AddTransaction event, Emitter<FinanceState> emit) async {
    try {
      final response = await SupabaseService.client.from('finances').insert({
        'amount': event.amount,
        'type': event.type,
        'description': event.description,
        'transaction_date': event.transactionDate.toIso8601String(),
      }).select();
      final newTransaction = Transaction.fromJson(response[0]);
      if (state is FinanceLoaded) {
        final updatedTransactions =
            List<Transaction>.from((state as FinanceLoaded).transactions)
              ..add(newTransaction);
        emit(FinanceLoaded(updatedTransactions));
      }
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }
}
