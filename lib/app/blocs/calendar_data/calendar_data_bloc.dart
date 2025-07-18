import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/app/models/todo_item.dart';
import 'package:myapp/app/models/transaction.dart';
import 'package:myapp/app/services/supabase_service.dart';

part 'calendar_data_event.dart';
part 'calendar_data_state.dart';

class CalendarDataBloc extends Bloc<CalendarDataEvent, CalendarDataState> {
  CalendarDataBloc() : super(CalendarDataInitial()) {
    on<FetchCalendarData>(_onFetchCalendarData);
  }

  Future<void> _onFetchCalendarData(
      FetchCalendarData event, Emitter<CalendarDataState> emit) async {
    emit(CalendarDataLoading());
    try {
      final todoResponse = await SupabaseService.client
          .from('todos')
          .select()
          .gte('created_at', event.startDate.toIso8601String())
          .lte('created_at', event.endDate.toIso8601String());

      final transactionResponse = await SupabaseService.client
          .from('transactions')
          .select()
          .gte('transaction_date', event.startDate.toIso8601String())
          .lte('transaction_date', event.endDate.toIso8601String());

      final todos = (todoResponse as List).map((json) => Todo.fromJson(json)).toList();
      final transactions =
          (transactionResponse as List).map((json) => Transaction.fromJson(json)).toList();

      final events = [...todos, ...transactions];
      emit(CalendarDataLoaded(events));
    } catch (e) {
      emit(CalendarDataError(e.toString()));
    }
  }
}
