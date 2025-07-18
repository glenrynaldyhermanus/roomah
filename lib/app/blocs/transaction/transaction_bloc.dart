import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/app/models/transaction.dart';
import 'package:myapp/app/services/supabase_service.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionInitial()) {
    on<FetchTransactions>(_onFetchTransactions);
    on<AddTransaction>(_onAddTransaction);
  }

  Future<void> _onFetchTransactions(
      FetchTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final response = await SupabaseService.client.from('transactions').select();
      final transactions =
          (response as List).map((json) => Transaction.fromJson(json)).toList();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
      AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      final response = await SupabaseService.client.from('transactions').insert({
        'amount': event.amount,
        'type': event.type,
        'description': event.description,
        'transaction_date': event.transactionDate.toIso8601String(),
      }).select();
      final newTransaction = Transaction.fromJson(response[0]);
      if (state is TransactionLoaded) {
        final updatedTransactions =
            List<Transaction>.from((state as TransactionLoaded).transactions)
              ..add(newTransaction);
        emit(TransactionLoaded(updatedTransactions));
      }
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
