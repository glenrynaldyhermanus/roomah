import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/blocs/routines/routines_bloc.dart';
import 'package:myapp/app/blocs/routines/routines_event.dart';
import 'package:myapp/app/blocs/routines/routines_state.dart';
import 'package:myapp/app/blocs/routine_categories/routine_categories_bloc.dart';
import 'package:myapp/app/blocs/routine_categories/routine_categories_event.dart';
import 'package:myapp/app/blocs/routine_categories/routine_categories_state.dart';
import 'package:myapp/app/models/routine.dart';
import 'package:myapp/app/models/routine_category.dart';
import 'package:myapp/app/widgets/neuma_widgets.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  RoutinesScreenState createState() => RoutinesScreenState();
}

class RoutinesScreenState extends State<RoutinesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RoutinesBloc>().add(const LoadRoutines());
    context.read<RoutineCategoriesBloc>().add(const LoadRoutineCategories());
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicBackground(
      child: Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        appBar: NeumorphicAppBar(
          title: const Text('Routines'),
          centerTitle: true,
        ),
        body: BlocBuilder<RoutinesBloc, RoutinesState>(
          builder: (context, state) {
            if (state is RoutinesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is RoutinesLoaded) {
              return BlocBuilder<RoutineCategoriesBloc, RoutineCategoriesState>(
                builder: (context, categoriesState) {
                  if (categoriesState is RoutineCategoriesLoaded) {
                    final activeRoutines = state.routines.where((r) => r.isActive).toList();
                    final inactiveRoutines = state.routines.where((r) => !r.isActive).toList();
                    
                    return Column(
                      children: [
                        if (activeRoutines.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Active Routines',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: _buildRoutinesByCategory(activeRoutines, categoriesState.categories),
                            ),
                          ),
                        ],
                        if (inactiveRoutines.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Inactive Routines',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: _buildRoutinesByCategory(inactiveRoutines, categoriesState.categories),
                            ),
                          ),
                        ],
                        if (state.routines.isEmpty)
                          const Center(
                            child: Text('No routines yet. Add your first routine!'),
                          ),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            }
            if (state is RoutinesError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('No Routines'));
          },
        ),
        floatingActionButton: NeumaButton(
          onPressed: () {
            context.go('/routines/form');
          },
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildRoutineItem(BuildContext context, Routine routine) {
    final now = DateTime.now();
    final isOverdue = routine.nextDueDate.isBefore(now);
    final isDueToday = routine.nextDueDate.day == now.day && 
                      routine.nextDueDate.month == now.month && 
                      routine.nextDueDate.year == now.year;
    
    return NeumaCard(
      child: Column(
        children: [
          Row(
            children: [
              NeumaButton(
                onPressed: routine.isActive ? () {
                  context.read<RoutinesBloc>().add(CompleteRoutine(routine.id));
                } : null,
                child: Icon(
                  routine.isActive ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: routine.isActive ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: routine.isActive ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                    if (routine.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        routine.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: isOverdue ? Colors.red : 
                                 isDueToday ? Colors.orange : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getFrequencyText(routine),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Due: ${DateFormat.yMMMd().format(routine.nextDueDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue ? Colors.red : 
                                   isDueToday ? Colors.orange : Colors.grey[600],
                            fontWeight: isOverdue || isDueToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    if (routine.lastCompletedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Last completed: ${DateFormat.yMMMd().format(routine.lastCompletedAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
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
                              context.go('/routines/form', extra: routine);
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              routine.isActive ? Icons.pause : Icons.play_arrow,
                            ),
                            title: Text(routine.isActive ? 'Pause' : 'Activate'),
                            onTap: () {
                              Navigator.pop(context);
                              context.read<RoutinesBloc>().add(ToggleRoutineActive(routine.id));
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
                              context.read<RoutinesBloc>().add(DeleteRoutine(routine.id));
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
        ],
      ),
    );
  }

  String _getFrequencyText(Routine routine) {
    switch (routine.frequencyType) {
      case 'daily':
        return routine.frequencyValue == 1 ? 'Daily' : 'Every ${routine.frequencyValue} days';
      case 'weekly':
        return routine.frequencyValue == 1 ? 'Weekly' : 'Every ${routine.frequencyValue} weeks';
      case 'monthly':
        return routine.frequencyValue == 1 ? 'Monthly' : 'Every ${routine.frequencyValue} months';
      case 'custom':
        return 'Every ${routine.frequencyValue} days';
      default:
        return 'Custom';
    }
  }

  List<Widget> _buildRoutinesByCategory(List<Routine> routines, List<RoutineCategory> categories) {
    // Group routines by category
    final Map<String?, List<Routine>> groupedRoutines = {};
    
    for (final routine in routines) {
      final categoryId = routine.categoryId;
      if (!groupedRoutines.containsKey(categoryId)) {
        groupedRoutines[categoryId] = [];
      }
      groupedRoutines[categoryId]!.add(routine);
    }

    final List<Widget> widgets = [];
    
    // Sort categories to show uncategorized first, then by name
    final sortedCategories = categories.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    
    // Add uncategorized routines first
    if (groupedRoutines.containsKey(null) && groupedRoutines[null]!.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Uncategorized',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
      widgets.addAll(
        groupedRoutines[null]!.map((routine) => _buildRoutineItem(context, routine)),
      );
    }

    // Add categorized routines
    for (final category in sortedCategories) {
      if (groupedRoutines.containsKey(category.id) && groupedRoutines[category.id]!.isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(int.parse('0xFF${category.color.substring(1)}')),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
        widgets.addAll(
          groupedRoutines[category.id]!.map((routine) => _buildRoutineItem(context, routine)),
        );
      }
    }

    return widgets;
  }
} 