import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/app/models/todo_item.dart';
import 'package:myapp/app/services/supabase_service.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodoBloc() : super(TodoInitial()) {
    on<FetchTodos>(_onFetchTodos);
    on<AddTodo>(_onAddTodo);
  }

  Future<void> _onFetchTodos(FetchTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final response = await SupabaseService.client.from('todos').select();
      final todos = (response as List).map((json) => Todo.fromJson(json)).toList();
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    try {
      final response = await SupabaseService.client.from('todos').insert({'title': event.title}).select();
      final newTodo = Todo.fromJson(response[0]);
      if (state is TodoLoaded) {
        final updatedTodos = List<Todo>.from((state as TodoLoaded).todos)..add(newTodo);
        emit(TodoLoaded(updatedTodos));
      }
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }
}
