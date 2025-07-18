part of 'calendar_data_bloc.dart';

abstract class CalendarDataEvent extends Equatable {
  const CalendarDataEvent();

  @override
  List<Object> get props => [];
}

class FetchCalendarData extends CalendarDataEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FetchCalendarData(this.startDate, this.endDate);

  @override
  List<Object> get props => [startDate, endDate];
}
