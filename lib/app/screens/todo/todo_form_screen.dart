import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/app/blocs/todo/todo_bloc.dart';
import 'package:myapp/app/models/todo_item.dart';
import 'package:myapp/app/widgets/neumorphic_widgets.dart';

class TodoFormScreen extends StatefulWidget {
  final Todo? todo;

  const TodoFormScreen({super.key, this.todo});

  @override
  _TodoFormScreenState createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.todo?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              NeumorphicTextField(
                controller: _titleController,
                labelText: 'Title',
                prefixIcon: const Icon(Icons.title),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              NeumorphicTextField(
                controller: _descriptionController,
                labelText: 'Description',
                prefixIcon: const Icon(Icons.description),
              ),
              const SizedBox(height: 20),
              NeumorphicButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final todo = Todo(
                      id: widget.todo?.id ?? DateTime.now().toIso8601String(),
                      title: _titleController.text,
                      description: _descriptionController.text,
                      isCompleted: widget.todo?.isCompleted ?? false,
                      createdAt: widget.todo?.createdAt ?? DateTime.now(),
                    );
                    if (widget.todo == null) {
                      context.read<TodoBloc>().add(AddTodo(todo));
                    } else {
                      context.read<TodoBloc>().add(UpdateTodo(todo));
                    }
                    Navigator.of(context).pop();
                  }
                },
                depth: 10.0,
                borderRadius: 16.0,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
