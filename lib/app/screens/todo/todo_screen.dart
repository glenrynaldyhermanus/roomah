import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/blocs/todo/todo_bloc.dart';
import 'package:myapp/app/models/todo_item.dart';
import 'package:myapp/app/widgets/neumorphic_widgets.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        title: const Text('To-Do List'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
                  child: ListView(
                    children:
                        state.todos
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
                    children: _buildCompletedGroups(
                      context,
                      state.completedTodos,
                    ),
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
      floatingActionButton: NeumorphicButton(
        onPressed: () {
          context.go('/todo/form');
        },
        depth: 12.0,
        borderRadius: 28.0,
        padding: const EdgeInsets.all(16.0),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  Widget _buildTodoItem(BuildContext context, Todo todo) {
    return NeumorphicCard(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            NeumorphicButton(
              onPressed: () {
                final updatedTodo = todo.copyWith(
                  isCompleted: !todo.isCompleted,
                  completedAt: !todo.isCompleted ? DateTime.now() : null,
                  clearCompletedAt: todo.isCompleted,
                );
                context.read<TodoBloc>().add(UpdateTodo(updatedTodo));
              },
              depth: 4.0,
              borderRadius: 8.0,
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                todo.isCompleted ? Icons.check : Icons.radio_button_unchecked,
                size: 20,
                color: todo.isCompleted ? Colors.green[600] : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          todo.isCompleted ? Colors.grey[600] : Colors.black87,
                      decoration:
                          todo.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (todo.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      todo.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        decoration:
                            todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            NeumorphicButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder:
                      (context) => Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Edit'),
                              onTap: () {
                                Navigator.pop(context);
                                context.go('/todo/form', extra: todo);
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              title: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                context.read<TodoBloc>().add(DeleteTodo(todo));
                              },
                            ),
                          ],
                        ),
                      ),
                );
              },
              depth: 4.0,
              borderRadius: 8.0,
              padding: const EdgeInsets.all(8.0),
              child: const Icon(Icons.more_vert, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCompletedGroups(
    BuildContext context,
    List<Todo> completedTodos,
  ) {
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
