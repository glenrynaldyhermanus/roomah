import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/blocs/finance/finance_bloc.dart';
import 'package:myapp/app/widgets/neuma_widgets.dart';
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
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    context.read<FinanceBloc>().add(FetchFinances());
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicBackground(
      child: Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        appBar: NeumorphicAppBar(title: const Text('Finance')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: NeumaToggle(
                selectedIndex: _tabController.index,
                options: const ['Finances', 'Budget'],
                onChanged: (int index) {
                  _tabController.animateTo(index);
                },
                height: 50,
                activeColor: Colors.blue[600],
                activeTextColor: Colors.white,
                inactiveTextColor: Colors.grey[700],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildFinancesView(), _buildBudgetView()],
              ),
            ),
          ],
        ),
        floatingActionButton: NeumaButton(
          onPressed: () {
            context.push('/finance/form');
          },
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFinancesView() {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        if (state is FinanceLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }
        if (state is FinanceLoaded) {
          if (state.finances.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Neumorphic(
                    style: const NeumorphicStyle(
                      depth: 8,
                      boxShape: NeumorphicBoxShape.circle(),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Icon(
                      PhosphorIcons.creditCard(),
                      size: 80,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No finances yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first finance item to get started',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.finances.length,
            itemBuilder: (context, index) {
              final finance = state.finances[index];
              return NeumaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            finance.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Neumorphic(
                          style: NeumorphicStyle(
                            color: Colors.blue.withAlpha(30),
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(12),
                            ),
                            depth: 2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 6.0,
                          ),
                          child: Text(
                            'Budget',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 20,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          finance.amount.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${finance.startDate.toLocal().toString().split(' ')[0]} - ${finance.endDate.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }
        if (state is FinanceError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Neumorphic(
                  style: const NeumorphicStyle(
                    depth: 8,
                    boxShape: NeumorphicBoxShape.circle(),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Icon(
                    PhosphorIcons.warning(),
                    size: 80,
                    color: Colors.orange[600],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Connection Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 24),
                NeumaButton(
                  onPressed: () {
                    context.read<FinanceBloc>().add(FetchFinances());
                  },

                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Center(
          child: Neumorphic(
            style: const NeumorphicStyle(
              depth: 8,
              boxShape: NeumorphicBoxShape.circle(),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Icon(
              PhosphorIcons.creditCard(),
              size: 80,
              color: Colors.grey[600],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBudgetView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Neumorphic(
            style: const NeumorphicStyle(
              depth: 8,
              boxShape: NeumorphicBoxShape.circle(),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Icon(
              PhosphorIcons.wallet(),
              size: 80,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Budget Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Coming soon...',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
