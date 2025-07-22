import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/blocs/routines/routines_bloc.dart';
import 'package:myapp/app/blocs/routines/routines_event.dart';
import 'package:myapp/app/blocs/routines/routines_state.dart';
import 'package:myapp/app/models/routine.dart';
import 'package:myapp/app/screens/ui_demo/ui_demo_screen.dart';
import 'package:myapp/app/widgets/neuma_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedViewIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            NeumaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.home, size: 32, color: Colors.blue[600]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Selamat Datang di Rumah Anda!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kelola rumah tangga Anda dengan mudah',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // View Toggle
            NeumaToggle(
              selectedIndex: _selectedViewIndex,
              options: const ['Ringkasan', 'Aktivitas', 'Laporan'],
              onChanged: (index) => setState(() => _selectedViewIndex = index),
              height: 45,
              activeColor: Colors.purple[600],
              activeTextColor: Colors.white,
              inactiveTextColor: Colors.grey[700],
            ),
            const SizedBox(height: 16),
            
            // Quick Stats
            const Text(
              'Ringkasan Hari Ini',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Todo',
                    '5',
                    '3 selesai',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Keuangan',
                    'Rp 2.5M',
                    '+Rp 500K',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Kalender',
                    '3',
                    'acara hari ini',
                    Icons.calendar_today,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Routines',
                    '2',
                    'due hari ini',
                    Icons.repeat,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Routines Section
            const Text(
              'Routines Hari Ini',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            BlocBuilder<RoutinesBloc, RoutinesState>(
              builder: (context, state) {
                if (state is RoutinesLoaded) {
                  final todayRoutines = state.routines.where((routine) {
                    final today = DateTime.now();
                    return routine.isActive && 
                           routine.nextDueDate.day == today.day &&
                           routine.nextDueDate.month == today.month &&
                           routine.nextDueDate.year == today.year;
                  }).toList();
                  
                  if (todayRoutines.isEmpty) {
                    return NeumaCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Tidak ada routines yang jatuh tempo hari ini',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  }
                  
                  return Column(
                    children: todayRoutines.take(3).map((routine) => 
                      _buildRoutineCard(context, routine)
                    ).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),

            // Recent Activities
            const Text(
              'Aktivitas Terbaru',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActivityCard(
              'Bayar tagihan listrik',
              'Rp 450.000',
              '2 jam yang lalu',
              Icons.electric_bolt,
              Colors.yellow[700]!,
            ),
            const SizedBox(height: 8),
            _buildActivityCard(
              'Belanja bulanan',
              'Rp 750.000',
              '1 hari yang lalu',
              Icons.shopping_basket,
              Colors.green[600]!,
            ),
            const SizedBox(height: 8),
            _buildActivityCard(
              'Rapat keluarga',
              'Minggu depan',
              '2 hari yang lalu',
              Icons.family_restroom,
              Colors.blue[600]!,
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Aksi Cepat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'Tambah Todo',
                    Icons.add_task,
                    Colors.green,
                    () {
                      context.go('/todo/form');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'Catat Keuangan',
                    Icons.add_chart,
                    Colors.blue,
                    () {
                      context.go('/finance/form');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'Tambah Routine',
                    Icons.repeat,
                    Colors.purple,
                    () {
                      context.go('/routines/form');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'Jadwal Acara',
                    Icons.event,
                    Colors.orange,
                    () {
                      context.go('/calendar');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'Laporan Bulanan',
                    Icons.assessment,
                    Colors.purple,
                    () {
                      // Show monthly report
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'UI Demo',
                    Icons.widgets,
                    Colors.teal,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const UiDemoScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard(BuildContext context, Routine routine) {
    return NeumaCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.repeat, color: Colors.purple[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
            NeumaButton(
              onPressed: () {
                context.read<RoutinesBloc>().add(CompleteRoutine(routine.id));
              },
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return NeumaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    String title,
    String amount,
    String time,
    IconData icon,
    Color color,
  ) {
    return NeumaCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return NeumaButton(
      onPressed: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
