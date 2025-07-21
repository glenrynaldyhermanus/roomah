import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/app/models/todo_item.dart';
import 'package:myapp/app/models/finance.dart';

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
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String());
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
}
