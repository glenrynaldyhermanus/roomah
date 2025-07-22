import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:myapp/app/blocs/routines/routines_bloc.dart';
import 'package:myapp/app/blocs/routines/routines_event.dart';
import 'package:myapp/app/blocs/routine_categories/routine_categories_bloc.dart';
import 'package:myapp/app/blocs/routine_categories/routine_categories_event.dart';
import 'package:myapp/app/blocs/routine_categories/routine_categories_state.dart';
import 'package:myapp/app/models/routine.dart';
import 'package:myapp/app/widgets/neuma_widgets.dart';

class RoutinesFormScreen extends StatefulWidget {
  final Routine? routine;

  const RoutinesFormScreen({super.key, this.routine});

  @override
  RoutinesFormScreenState createState() => RoutinesFormScreenState();
}

class RoutinesFormScreenState extends State<RoutinesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _frequencyValueController;
  String _selectedFrequencyType = 'weekly';
  String? _selectedCategoryId;
  DateTime _nextDueDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.routine?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.routine?.description ?? '',
    );
    _frequencyValueController = TextEditingController(
      text: widget.routine?.frequencyValue.toString() ?? '1',
    );
    if (widget.routine != null) {
      _selectedFrequencyType = widget.routine!.frequencyType;
      _selectedCategoryId = widget.routine!.categoryId;
      _nextDueDate = widget.routine!.nextDueDate;
    }
    // Load categories
    context.read<RoutineCategoriesBloc>().add(const LoadRoutineCategories());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _frequencyValueController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final routine = Routine(
        id: widget.routine?.id ?? DateTime.now().toIso8601String(),
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        categoryId: _selectedCategoryId,
        frequencyType: _selectedFrequencyType,
        frequencyValue: int.parse(_frequencyValueController.text),
        lastCompletedAt: widget.routine?.lastCompletedAt,
        nextDueDate: _nextDueDate,
        isActive: widget.routine?.isActive ?? true,
        createdAt: widget.routine?.createdAt ?? DateTime.now(),
      );
      
      if (widget.routine == null) {
        context.read<RoutinesBloc>().add(AddRoutine(routine));
      } else {
        context.read<RoutinesBloc>().add(UpdateRoutine(routine));
      }
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _nextDueDate) {
      setState(() {
        _nextDueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        title: Text(widget.routine == null ? 'Add Routine' : 'Edit Routine'),
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
                hintText: 'Routine Title',
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
                hintText: 'Description (optional)',
                icon: Icons.description,
              ),
              const SizedBox(height: 16),
              NeumaCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<RoutineCategoriesBloc, RoutineCategoriesState>(
                        builder: (context, state) {
                          if (state is RoutineCategoriesLoaded) {
                            return DropdownButtonFormField<String>(
                              value: _selectedCategoryId,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              hint: const Text('Select Category'),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('No Category'),
                                ),
                                ...state.categories.map((category) => DropdownMenuItem<String>(
                                  value: category.id,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Color(int.parse('0xFF${category.color.substring(1)}')),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(category.name),
                                    ],
                                  ),
                                )),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                });
                              },
                            );
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              NeumaCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frequency',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedFrequencyType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'daily', child: Text('Daily')),
                          DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                          DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                          DropdownMenuItem(value: 'custom', child: Text('Custom (days)')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFrequencyType = value!;
                            if (_selectedFrequencyType == 'daily') {
                              _frequencyValueController.text = '1';
                            } else if (_selectedFrequencyType == 'weekly') {
                              _frequencyValueController.text = '1';
                            } else if (_selectedFrequencyType == 'monthly') {
                              _frequencyValueController.text = '1';
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: NeumaTextField.compact(
                              controller: _frequencyValueController,
                              hintText: 'Value',
                              icon: Icons.numbers,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }
                                final intValue = int.tryParse(value);
                                if (intValue == null || intValue <= 0) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _getFrequencyLabel(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              NeumaCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Due Date',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          '${_nextDueDate.day}/${_nextDueDate.month}/${_nextDueDate.year}',
                        ),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () => _selectDate(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              NeumaButton(
                onPressed: _submit,
                child: Text(widget.routine == null ? 'Add Routine' : 'Update Routine'),
              ),
              const SizedBox(height: 40), // Extra padding for keyboard
            ],
          ),
        ),
      ),
    );
  }

  String _getFrequencyLabel() {
    switch (_selectedFrequencyType) {
      case 'daily':
        return 'day(s)';
      case 'weekly':
        return 'week(s)';
      case 'monthly':
        return 'month(s)';
      case 'custom':
        return 'day(s)';
      default:
        return '';
    }
  }
} 