import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/blocs/todo/todo_bloc.dart';
import 'package:myapp/app/models/todo_item.dart';
import 'package:myapp/app/widgets/neuma_widgets.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  TodoScreenState createState() => TodoScreenState();
}

class TodoScreenState extends State<TodoScreen> {
  @override
  Widget build(BuildContext context) {
    return NeumorphicBackground(
      child: Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        appBar: NeumorphicAppBar(
          title: const Text('To-Do List'),
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
        floatingActionButton: NeumaButton(
          onPressed: () {
            context.go('/todo/form');
          },
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTodoItem(BuildContext context, Todo todo) {
    return NeumaCard(
      child: Row(
        children: [
          NeumaButton(
            onPressed: () {
              final updatedTodo = todo.copyWith(
                isCompleted: !todo.isCompleted,
                completedAt: !todo.isCompleted ? DateTime.now() : null,
                clearCompletedAt: todo.isCompleted,
              );
              context.read<TodoBloc>().add(UpdateTodo(updatedTodo));
            },
            child: Icon(
              todo.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: todo.isCompleted ? Colors.green : Colors.grey,
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
                    color: todo.isCompleted ? Colors.grey[600] : Colors.black87,
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
                          todo.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
          NeumaButton(
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
            child: const Icon(Icons.more_vert, size: 20),
          ),
        ],
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
