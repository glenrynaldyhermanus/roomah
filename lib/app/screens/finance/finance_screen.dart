import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:myapp/app/blocs/finance/finance_bloc.dart';
import 'package:myapp/app/themes/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Add a listener to rebuild the widget when the tab changes.
    // This ensures the NeumorphicToggle's style updates correctly.
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    // Fetch initial data
    context.read<FinanceBloc>().add(FetchTransactions());
  }

  @override
  void dispose() {
    // It's good practice to remove the listener, though dispose() also handles it.
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: const Text('Finance'),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: NeumorphicToggle(
              selectedIndex: _tabController.index,
              onChanged: (int index) {
                _tabController.animateTo(index);
              },
              height: 40,
              children: [
                ToggleElement(
                  background: Center(
                    child: Text(
                      'Transactions',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _tabController.index == 0
                            ? AppTheme.textColor
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                ToggleElement(
                  background: Center(
                    child: Text(
                      'Budget',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _tabController.index == 1
                            ? AppTheme.textColor
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
              thumb: Neumorphic(
                style: NeumorphicStyle(
                  color: AppTheme.accentColor,
                  boxShape: NeumorphicBoxShape.roundRect(
                      const BorderRadius.all(Radius.circular(12))),
                ),
              ),
              style: NeumorphicToggleStyle(
                depth: 2,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsView(),
                _buildBudgetView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: NeumorphicFloatingActionButton(
        onPressed: () {
          // TODO: Implement add transaction or budget item dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionsView() {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        if (state is FinanceLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FinanceLoaded) {
          if (state.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeumorphicIcon(
                    PhosphorIcons.creditCard(),
                    size: 100,
                    style: const NeumorphicStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Text('No transactions yet.'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: state.transactions.length,
            itemBuilder: (context, index) {
              final transaction = state.transactions[index];
              return Neumorphic(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                padding: const EdgeInsets.all(16.0),
                child: ListTile(
                  title: Text(transaction.description ?? 'No description'),
                  subtitle: Text(
                      '${transaction.amount} - ${transaction.transactionDate.toLocal().toString().split(' ')[0]}'),
                  trailing: Text(transaction.type,
                      style: TextStyle(
                          color: transaction.type == 'income'
                              ? Colors.green
                              : Colors.red)),
                ),
              );
            },
          );
        }
        if (state is FinanceError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return Center(
          child: NeumorphicIcon(
            PhosphorIcons.creditCard(),
            size: 100,
            style: const NeumorphicStyle(color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildBudgetView() {
    // Placeholder for the budget feature.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeumorphicIcon(
            PhosphorIcons.wallet(),
            size: 100,
            style: const NeumorphicStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const Text('Budget overview will be here.'),
        ],
      ),
    );
  }
}
