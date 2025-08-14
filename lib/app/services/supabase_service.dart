import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/app/models/todo_item.dart';
import 'package:myapp/app/models/finance.dart';
import 'package:myapp/app/models/routine.dart';
import 'package:myapp/app/models/routine_category.dart';
import 'package:myapp/app/models/calendar_event.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Finance>> getFinances() async {
    try {
      final data = await _client
          .from('finances')
          .select()
          .timeout(const Duration(seconds: 10));
      return (data as List).map((json) => Finance.fromJson(json)).toList();
    } catch (e) {
      if (e.toString().contains('rrno = 7') || 
          e.toString().contains('no address associated with hostname')) {
        throw Exception('Network error: Unable to resolve hostname. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<List<Finance>> getFinancesByDateRange(DateTime start, DateTime end) async {
    try {
      final data = await _client
          .from('finances')
          .select()
          .gte('start_date', start.toIso8601String())
          .lte('end_date', end.toIso8601String())

          .timeout(const Duration(seconds: 10));
      return (data as List).map((json) => Finance.fromJson(json)).toList();
    } catch (e) {
      if (e.toString().contains('rrno = 7') || 
          e.toString().contains('no address associated with hostname')) {
        throw Exception('Network error: Unable to resolve hostname. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<void> addFinance(Finance finance) async {
    try {
      await _client
          .from('finances')
          .insert(finance.toJson())
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e.toString().contains('rrno = 7') || 
          e.toString().contains('no address associated with hostname')) {
        throw Exception('Network error: Unable to resolve hostname. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<List<Todo>> getTodos() async {
    final data = await _client.from('todos').select();
    return (data as List).map((json) => Todo.fromJson(json)).toList();
  }

  Future<List<Todo>> getTodosByDateRange(DateTime start, DateTime end) async {
    final data = await _client
        .from('todos')
        .select()
        .or('and(due_date.gte.${start.toIso8601String()},due_date.lte.${end.toIso8601String()}),and(due_date.is.null,created_at.gte.${start.toIso8601String()},created_at.lte.${end.toIso8601String()})');
    return (data as List).map((json) => Todo.fromJson(json)).toList();
  }

  Future<void> addTodo(Todo todo) async {
    await _client.from('todos').insert(todo.toJson());
  }

  Future<void> updateTodo(Todo todo) async {
    await _client.from('todos').update(todo.toJson()).eq('id', todo.id);
  }

  Future<void> deleteTodo(String id) async {
    await _client.from('todos').delete().eq('id', id);
  }

  // Routine Categories methods
  Future<List<RoutineCategory>> getRoutineCategories() async {
    try {
      final data = await _client
          .from('routine_categories')
          .select()
          .order('name', ascending: true)
          .timeout(const Duration(seconds: 10));
      return (data as List).map((json) => RoutineCategory.fromJson(json)).toList();
    } catch (e) {
      if (e.toString().contains('rrno = 7') || 
          e.toString().contains('no address associated with hostname')) {
        throw Exception('Network error: Unable to resolve hostname. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<void> addRoutineCategory(RoutineCategory category) async {
    try {
      await _client
          .from('routine_categories')
          .insert(category.toJson())
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e.toString().contains('rrno = 7') || 
          e.toString().contains('no address associated with hostname')) {
        throw Exception('Network error: Unable to resolve hostname. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<void> updateRoutineCategory(RoutineCategory category) async {
    try {
      await _client
          .from('routine_categories')
          .update(category.toJson())
          .eq('id', category.id)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e.toString().contains('rrno = 7') || 
          e.toString().contains('no address associated with hostname')) {
        throw Exception('Network error: Unable to resolve hostname. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<void> deleteRoutineCategory(String id) async {
    try {
      await _client
          .from('routine_categories')
          .delete()
          .eq('id', id)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e.toString().contains('rrno = 7') || 
          e.toString().contains('no address associated with hostname')) {
        throw Exception('Network error: Unable to resolve hostname. Please check your internet connection.');
      }
      rethrow;
    }
  }

  // Routines methods
  Future<List<Routine>> getRoutines() async {
    try {
      final data = await _client
          .from('routines')
          .select('*, routine_categories(*)')
          .order('next_due_date', ascending: true)
          .timeout(const Duration(seconds: 10));
      return (data as List).map((json) => Routine.fromJson(json)).toList();
    } catch (e) {
      if (e.toString().contains('rrno = 7') || 
          e.toString().contains('no address associated with hostname')) {
        throw Exception('Network error: Unable to resolve hostname. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<void> addRoutine(Routine routine) async {
    try {
      await _client
          .from('routines')
          .insert(routine.toJson())
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e.toString().contains('rrno = 7') || 
          e.toString().contains('no address associated with hostname')) {
        throw Exception('Network error: Unable to resolve hostname. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<void> updateRoutine(Routine routine) async {
    try {
      await _client
          .from('routines')
          .update(routine.toJson())
          .eq('id', routine.id)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e.toString().contains('rrno = 7') || 
          e.toString().contains('no address associated with hostname')) {
        throw Exception('Network error: Unable to resolve hostname. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<void> deleteRoutine(String id) async {
    try {
      await _client
          .from('routines')
          .delete()
          .eq('id', id)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e.toString().contains('rrno = 7') || 
          e.toString().contains('no address associated with hostname')) {
        throw Exception('Network error: Unable to resolve hostname. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<void> completeRoutine(String id) async {
    try {
      final now = DateTime.now();
      final routine = await _client
          .from('routines')
          .select()
          .eq('id', id)
          .single();
      
      final currentRoutine = Routine.fromJson(routine);
      DateTime nextDueDate;
      
      switch (currentRoutine.frequencyType) {
        case 'daily':
          nextDueDate = now.add(Duration(days: currentRoutine.frequencyValue));
          break;
        case 'weekly':
          nextDueDate = now.add(Duration(days: currentRoutine.frequencyValue * 7));
          break;
        case 'monthly':
          nextDueDate = DateTime(now.year, now.month + currentRoutine.frequencyValue, now.day);
          break;
        case 'custom':
          nextDueDate = now.add(Duration(days: currentRoutine.frequencyValue));
          break;
        default:
          nextDueDate = now.add(const Duration(days: 1));
      }

      await _client
          .from('routines')
          .update({
            'last_completed_at': now.toIso8601String(),
            'next_due_date': nextDueDate.toIso8601String(),
          })
          .eq('id', id)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e.toString().contains('rrno = 7') || 
          e.toString().contains('no address associated with hostname')) {
        throw Exception('Network error: Unable to resolve hostname. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<void> toggleRoutineActive(String id) async {
    try {
      final routine = await _client
          .from('routines')
          .select('is_active')
          .eq('id', id)
          .single();
      
      await _client
          .from('routines')
          .update({'is_active': !routine['is_active']})
          .eq('id', id)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e.toString().contains('rrno = 7') || 
          e.toString().contains('no address associated with hostname')) {
        throw Exception('Network error: Unable to resolve hostname. Please check your internet connection.');
      }
      rethrow;
    }
  }

  // Menunda rutinitas sejumlah hari dari next_due_date saat ini
  Future<void> snoozeRoutine(String id, int days) async {
    try {
      final routine = await _client
          .from('routines')
          .select('next_due_date')
          .eq('id', id)
          .single();

      final currentNext = DateTime.parse(routine['next_due_date'].toString());
      final updated = currentNext.add(Duration(days: days));

      await _client
          .from('routines')
          .update({'next_due_date': updated.toIso8601String()})
          .eq('id', id)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e.toString().contains('rrno = 7') || 
          e.toString().contains('no address associated with hostname')) {
        throw Exception('Network error: Unable to resolve hostname. Please check your internet connection.');
      }
      rethrow;
    }
  }

  // Calendar Events CRUD
  Future<List<CalendarEvent>> getCalendarEventsByDateRange(DateTime start, DateTime end) async {
    final data = await _client
        .from('calendar_events')
        .select()
        .gte('start_at', start.toIso8601String())
        .lte('start_at', end.toIso8601String());
    return (data as List).map((json) => CalendarEvent.fromJson(json)).toList();
  }

  Future<void> addCalendarEvent(CalendarEvent event) async {
    await _client.from('calendar_events').insert(event.toJson());
  }

  Future<void> updateCalendarEvent(CalendarEvent event) async {
    await _client.from('calendar_events').update(event.toJson()).eq('id', event.id);
  }

  Future<void> deleteCalendarEvent(String id) async {
    await _client.from('calendar_events').delete().eq('id', id);
  }
}
