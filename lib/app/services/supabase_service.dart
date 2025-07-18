import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/app/models/todo_item.dart';
import 'package:myapp/app/models/transaction.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Transaction>> getTransactions() async {
    final data = await _client.from('transactions').select();
    return (data as List).map((json) => Transaction.fromJson(json)).toList();
  }

  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final data = await _client
        .from('transactions')
        .select()
        .gte('transaction_date', start.toIso8601String())
        .lte('transaction_date', end.toIso8601String());
    return (data as List).map((json) => Transaction.fromJson(json)).toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _client.from('transactions').insert(transaction.toJson());
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
