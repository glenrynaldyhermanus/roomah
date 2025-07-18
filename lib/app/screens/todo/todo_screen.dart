import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/blocs/todo/todo_bloc.dart';
import 'package:myapp/app/models/todo_item.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: const Text('To-Do List'),
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TodoLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      context
                          .read<TodoBloc>()
                          .add(ReorderTodo(oldIndex, newIndex));
                    },
                    children: state.todos
                        .map((todo) => _buildTodoItem(context, todo))
                        .toList(),
                  ),
                ),
                if (state.completedTodos.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Completed',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                Expanded(
                  child: ListView(
                    children:
                        _buildCompletedGroups(context, state.completedTodos),
                  ),
                ),
              ],
            );
          }
          if (state is TodoError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No Todos'));
        },
      ),
      floatingActionButton: NeumorphicFloatingActionButton(
        onPressed: () {
          context.go('/todo/form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoItem(BuildContext context, Todo todo) {
    return ListTile(
      key: ValueKey(todo.id),
      leading: Checkbox(
        value: todo.isCompleted,
        onChanged: (value) {
          final updatedTodo = todo.copyWith(
            isCompleted: value,
            completedAt: value! ? DateTime.now() : null,
            clearCompletedAt: !value,
          );
          context.read<TodoBloc>().add(UpdateTodo(updatedTodo));
        },
      ),
      title: Text(todo.title),
      subtitle: todo.description != null ? Text(todo.description!) : null,
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
        onSelected: (value) {
          if (value == 'edit') {
            context.go('/todo/form', extra: todo);
          } else if (value == 'delete') {
            context.read<TodoBloc>().add(DeleteTodo(todo));
          }
        },
      ),
    );
  }

  List<Widget> _buildCompletedGroups(
      BuildContext context, List<Todo> completedTodos) {
    final groups = <String, List<Todo>>{};
    for (final todo in completedTodos) {
      final date = DateFormat.yMMMd().format(todo.completedAt!);
      if (groups[date] == null) {
        groups[date] = [];
      }
      groups[date]!.add(todo);
    }

    return groups.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              entry.key,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...entry.value.map((todo) => _buildTodoItem(context, todo)),
        ],
      );
    }).toList();
  }
}
