import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/app/models/todo_item.dart';
import 'package:myapp/app/services/supabase_service.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final SupabaseService _supabaseService;

  TodoBloc(this._supabaseService) : super(TodoInitial()) {
    on<FetchTodos>(_onFetchTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<ReorderTodo>(_onReorderTodo);
  }

  Future<void> _onFetchTodos(FetchTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todos = await _supabaseService.getTodos();
      final activeTodos = todos.where((todo) => !todo.isCompleted).toList();
      final completedTodos = todos.where((todo) => todo.isCompleted).toList();
      emit(TodoLoaded(todos: activeTodos, completedTodos: completedTodos));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    final currentState = state;
    if (currentState is TodoLoaded) {
      emit(TodoLoading());
      try {
        await _supabaseService.addTodo(event.todo);
        final todos = await _supabaseService.getTodos();
        final activeTodos = todos.where((todo) => !todo.isCompleted).toList();
        final completedTodos = todos.where((todo) => todo.isCompleted).toList();
        emit(TodoLoaded(todos: activeTodos, completedTodos: completedTodos));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    final currentState = state;
    if (currentState is TodoLoaded) {
      emit(TodoLoading());
      try {
        await _supabaseService.updateTodo(event.todo);
        final todos = await _supabaseService.getTodos();
        final activeTodos = todos.where((todo) => !todo.isCompleted).toList();
        final completedTodos = todos.where((todo) => todo.isCompleted).toList();
        emit(TodoLoaded(todos: activeTodos, completedTodos: completedTodos));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    final currentState = state;
    if (currentState is TodoLoaded) {
      emit(TodoLoading());
      try {
        await _supabaseService.deleteTodo(event.todo.id);
        final todos = await _supabaseService.getTodos();
        final activeTodos = todos.where((todo) => !todo.isCompleted).toList();
        final completedTodos = todos.where((todo) => todo.isCompleted).toList();
        emit(TodoLoaded(todos: activeTodos, completedTodos: completedTodos));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    }
  }

  void _onReorderTodo(ReorderTodo event, Emitter<TodoState> emit) {
    final currentState = state;
    if (currentState is TodoLoaded) {
      final todos = List<Todo>.from(currentState.todos);
      final todo = todos.removeAt(event.oldIndex);
      todos.insert(event.newIndex, todo);
      emit(TodoLoaded(todos: todos, completedTodos: currentState.completedTodos));
    }
  }
}
