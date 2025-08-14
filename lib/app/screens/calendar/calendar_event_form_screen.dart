import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/models/calendar_event.dart';
import 'package:myapp/app/services/supabase_service.dart';
import 'package:myapp/app/widgets/neuma_widgets.dart';

class CalendarEventFormScreen extends StatefulWidget {
  final CalendarEvent? event;

  const CalendarEventFormScreen({super.key, this.event});

  @override
  State<CalendarEventFormScreen> createState() => _CalendarEventFormScreenState();
}

class _CalendarEventFormScreenState extends State<CalendarEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  DateTime _startAt = DateTime.now();
  DateTime? _endAt;
  bool _allDay = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _locationController = TextEditingController(text: widget.event?.location ?? '');
    _startAt = widget.event?.startAt ?? DateTime.now();
    _endAt = widget.event?.endAt;
    _allDay = widget.event?.allDay ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _startAt = DateTime(picked.year, picked.month, picked.day, _startAt.hour, _startAt.minute);
      });
    }
  }

  Future<void> _pickEndDate() async {
    final base = _endAt ?? _startAt;
    final picked = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _endAt = DateTime(picked.year, picked.month, picked.day, base.hour, base.minute);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final svc = RepositoryProvider.of<SupabaseService>(context);
    final event = CalendarEvent(
      id: widget.event?.id ?? DateTime.now().toIso8601String(),
      title: _titleController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      startAt: _startAt,
      endAt: _endAt,
      allDay: _allDay,
      location: _locationController.text.isEmpty ? null : _locationController.text,
      createdAt: widget.event?.createdAt ?? DateTime.now(),
    );
    if (widget.event == null) {
      await svc.addCalendarEvent(event);
    } else {
      await svc.updateCalendarEvent(event);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
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
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              NeumaTextField.compact(
                controller: _descriptionController,
                hintText: 'Description',
                icon: Icons.description,
              ),
              const SizedBox(height: 12),
              NeumaTextField.compact(
                controller: _locationController,
                hintText: 'Location',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: NeumaCard(
                      child: Row(
                        children: [
                          const Icon(Icons.event, size: 18, color: Color(0xFFB0B0B0)),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Start: ${DateFormat.yMMMd().format(_startAt)}')),
                          NeumaButton(onPressed: _pickStartDate, child: const Text('Pick')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: NeumaCard(
                      child: Row(
                        children: [
                          const Icon(Icons.event_available, size: 18, color: Color(0xFFB0B0B0)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_endAt == null ? 'No end date' : 'End: ${DateFormat.yMMMd().format(_endAt!)}')),
                          NeumaButton(onPressed: _pickEndDate, child: const Text('Pick')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('All Day'),
                  Switch(
                    value: _allDay,
                    onChanged: (v) => setState(() => _allDay = v),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              NeumaButton(onPressed: _submit, child: Text(widget.event == null ? 'Add' : 'Update')),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}