import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/blocs/todo/todo_bloc.dart';
import 'package:myapp/app/models/todo_item.dart';
import 'package:myapp/app/widgets/neuma_widgets.dart';

class TodoFormScreen extends StatefulWidget {
  final Todo? todo;

  const TodoFormScreen({super.key, this.todo});

  @override
  TodoFormScreenState createState() => TodoFormScreenState();
}

class TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  int _priorityIndex = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.todo?.description ?? '',
    );
    _dueDate = widget.todo?.dueDate;
    _priorityIndex = widget.todo?.priority ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final initial = _dueDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final todo = Todo(
        id: widget.todo?.id ?? DateTime.now().toIso8601String(),
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        isCompleted: widget.todo?.isCompleted ?? false,
        createdAt: widget.todo?.createdAt ?? DateTime.now(),
        dueDate: _dueDate,
        priority: _priorityIndex,
      );
      if (widget.todo == null) {
        context.read<TodoBloc>().add(AddTodo(todo));
      } else {
        context.read<TodoBloc>().add(UpdateTodo(todo));
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Add Todo' : 'Edit Todo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              NeumaTextField.compact(
                controller: _titleController,
                hintText: 'Title',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              NeumaTextField.compact(
                controller: _descriptionController,
                hintText: 'Description',
                icon: Icons.description,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Priority',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              NeumaToggle(
                selectedIndex: _priorityIndex,
                options: const ['Low', 'Med', 'High'],
                onChanged: (index) => setState(() => _priorityIndex = index),
                height: 44,
                activeTextColor: Colors.white,
                inactiveTextColor: Colors.grey[700],
              ),
              const SizedBox(height: 16),
              NeumaCard(
                child: Row(
                  children: [
                    const Icon(Icons.event, size: 18, color: Color(0xFFB0B0B0)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _dueDate == null
                            ? 'No due date'
                            : 'Due: ${DateFormat.yMMMd().format(_dueDate!)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    NeumaButton(
                      onPressed: _pickDueDate,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('Pick Date'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              NeumaButton(
                onPressed: _submit,
                child: Text(widget.todo == null ? 'Add Todo' : 'Update Todo'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
