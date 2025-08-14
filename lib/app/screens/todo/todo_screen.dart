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
  int _sortIndex = 0; // 0: Created, 1: Due, 2: Priority

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
              final active = List<Todo>.from(state.todos);
              switch (_sortIndex) {
                case 1:
                  active.sort((a, b) {
                    final ad = a.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
                    final bd = b.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
                    return ad.compareTo(bd);
                  });
                  break;
                case 2:
                  active.sort((a, b) => b.priority.compareTo(a.priority));
                  break;
                default:
                  active.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              }

              final completed = List<Todo>.from(state.completedTodos);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: NeumaToggle(
                      selectedIndex: _sortIndex,
                      options: const ['Created', 'Due', 'Priority'],
                      onChanged: (index) => setState(() => _sortIndex = index),
                      height: 44,
                      activeTextColor: Colors.white,
                      inactiveTextColor: Colors.grey[700],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: active.map((todo) => _buildTodoItem(context, todo)).toList(),
                    ),
                  ),
                  if (completed.isNotEmpty)
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
                        completed,
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
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (todo.description != null && todo.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    todo.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (todo.dueDate != null) ...[
                      const Icon(Icons.event, size: 14, color: Colors.blueGrey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat.yMMMd().format(todo.dueDate!),
                        style: TextStyle(fontSize: 12, color: Colors.blueGrey[700]),
                      ),
                      const SizedBox(width: 12),
                    ],
                    const Icon(Icons.flag, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      ['Low', 'Med', 'High'][todo.priority.clamp(0, 2)],
                      style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                    ),
                  ],
                )
              ],
            ),
          ),
          NeumaButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
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
      groups[date] ??= [];
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
