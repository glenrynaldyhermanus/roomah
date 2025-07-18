import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:myapp/app/blocs/calendar_data/calendar_data_bloc.dart';
import 'package:myapp/app/models/todo_item.dart';
import 'package:myapp/app/models/transaction.dart';
import 'package:table_calendar/table_calendar.dart';

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
      appBar: NeumorphicAppBar(
        title: const Text('Calendar'),
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
                        return isSameDay(event.createdAt, day);
                      } else if (event is Transaction) {
                        return isSameDay(event.transactionDate, day);
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
                          subtitle: Text(event.createdAt.toString()),
                        );
                      } else if (event is Transaction) {
                        return ListTile(
                          title: Text('Transaction: ${event.description}'),
                          subtitle: Text(
                              '${event.amount} - ${event.transactionDate}'),
                          trailing: Text(event.type),
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
