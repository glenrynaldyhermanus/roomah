part of 'calendar_data_bloc.dart';

abstract class CalendarDataState extends Equatable {
  const CalendarDataState();

  @override
  List<Object> get props => [];
}

class CalendarDataInitial extends CalendarDataState {}

class CalendarDataLoading extends CalendarDataState {}

class CalendarDataLoaded extends CalendarDataState {
  final List<dynamic> events;

  const CalendarDataLoaded(this.events);

  @override
  List<Object> get props => [events];
}

class CalendarDataError extends CalendarDataState {
  final String message;

  const CalendarDataError(this.message);

  @override
  List<Object> get props => [message];
}
