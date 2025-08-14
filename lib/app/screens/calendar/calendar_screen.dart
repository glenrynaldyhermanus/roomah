import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/app/blocs/calendar_data/calendar_data_bloc.dart';
import 'package:myapp/app/services/supabase_service.dart';
import 'package:myapp/app/models/todo_item.dart';
import 'package:myapp/app/models/finance.dart';
import 'package:myapp/app/models/calendar_event.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    context.read<CalendarDataBloc>().add(FetchCalendarData(
          DateTime.utc(_focusedDay.year, _focusedDay.month, 1),
          DateTime.utc(_focusedDay.year, _focusedDay.month + 1, 0),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/calendar/event-form');
            },
          ),
        ],
      ),
      body: BlocBuilder<CalendarDataBloc, CalendarDataState>(
        builder: (context, state) {
          if (state is CalendarDataLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CalendarDataLoaded) {
            return Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  eventLoader: (day) {
                    return state.events.where((event) {
                      if (event is Todo) {
                        final todoDate = event.dueDate ?? event.createdAt;
                        return isSameDay(todoDate, day);
                      } else if (event is Finance) {
                        return isSameDay(event.startDate, day);
                      } else if (event is CalendarEvent) {
                        return isSameDay(event.startAt, day);
                      }
                      return false;
                    }).toList();
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.deepOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.events.length,
                    itemBuilder: (context, index) {
                      final event = state.events[index];
                                              if (event is Todo) {
                        return ListTile(
                          title: Text('Todo: ${event.title}'),
                          subtitle: Text((event.dueDate ?? event.createdAt).toString()),
                        );
                      } else if (event is Finance) {
                        return ListTile(
                          title: Text('Finance: ${event.name}'),
                          subtitle: Text('${event.amount} - ${event.startDate}'),
                          trailing: Text('Budget'),
                        );
                      } else if (event is CalendarEvent) {
                        return ListTile(
                          title: Text('Event: ${event.title}'),
                          subtitle: Text('${event.startAt}${event.allDay ? ' (All day)' : ''}'),
                          onTap: () {
                            context.push('/calendar/event-form', extra: event);
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () async {
                              final svc = RepositoryProvider.of<SupabaseService>(context);
                              await svc.deleteCalendarEvent(event.id);
                              final now = _focusedDay;
                              // refresh current month
                              context.read<CalendarDataBloc>().add(FetchCalendarData(
                                DateTime.utc(now.year, now.month, 1),
                                DateTime.utc(now.year, now.month + 1, 0),
                              ));
                            },
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                ),
              ],
            );
          }
          if (state is CalendarDataError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No data'));
        },
      ),
    );
  }
}
