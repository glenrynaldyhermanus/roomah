import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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
      final finances = await _supabaseService.getFinancesByDateRange(event.startDate, event.endDate);

              final events = [...todos, ...finances];
      emit(CalendarDataLoaded(events));
    } catch (e) {
      emit(CalendarDataError(e.toString()));
    }
  }
}
