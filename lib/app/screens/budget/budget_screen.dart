import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:myapp/app/blocs/budget/budget_bloc.dart';
import 'package:myapp/app/models/budget_item.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(FetchBudgets());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: const Text('Budget Manager'),
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BudgetLoaded) {
            return ListView.builder(
              itemCount: state.budgets.length,
              itemBuilder: (context, index) {
                final budget = state.budgets[index];
                return ListTile(
                  title: Text(budget.name),
                  subtitle: Text(
                      '${budget.amount} from ${budget.startDate} to ${budget.endDate}'),
                );
              },
            );
          }
          if (state is BudgetError) {
            return Center(child: Text(state.message));
          }
          return Center(
            child: NeumorphicIcon(
              PhosphorIcons.wallet(),
              size: 100,
            ),
          );
        },
      ),
      floatingActionButton: NeumorphicFloatingActionButton(
        onPressed: () {
          _showAddBudgetDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Enter budget name'),
              ),
              TextField(
                controller: amountController,
                decoration:
                    const InputDecoration(hintText: 'Enter budget amount'),
                keyboardType: TextInputType.number,
              ),
              // Implement date pickers for start and end dates
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<BudgetBloc>().add(AddBudget(
                      name: nameController.text,
                      amount: double.parse(amountController.text),
                      startDate: startDate ?? DateTime.now(),
                      endDate: endDate ?? DateTime.now().add(const Duration(days: 30)),
                    ));
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
