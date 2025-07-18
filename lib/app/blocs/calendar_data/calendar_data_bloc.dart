import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/app/models/todo_item.dart';
import 'package:myapp/app/models/transaction.dart';
import 'package:myapp/app/services/supabase_service.dart';

part 'calendar_data_event.dart';
part 'calendar_data_state.dart';

class CalendarDataBloc extends Bloc<CalendarDataEvent, CalendarDataState> {
  final SupabaseService _supabaseService;

  CalendarDataBloc(this._supabaseService) : super(CalendarDataInitial()) {
    on<FetchCalendarData>(_onFetchCalendarData);
  }

  Future<void> _onFetchCalendarData(
      FetchCalendarData event, Emitter<CalendarDataState> emit) async {
    emit(CalendarDataLoading());
    try {
      final todos = await _supabaseService.getTodosByDateRange(event.startDate, event.endDate);
      final transactions = await _supabaseService.getTransactionsByDateRange(event.startDate, event.endDate);

      final events = [...todos, ...transactions];
      emit(CalendarDataLoaded(events));
    } catch (e) {
      emit(CalendarDataError(e.toString()));
    }
  }
}
