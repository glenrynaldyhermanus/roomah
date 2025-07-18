part of 'todo_bloc.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

class FetchTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final String title;

  const AddTodo(this.title);

  @override
  List<Object> get props => [title];
}
