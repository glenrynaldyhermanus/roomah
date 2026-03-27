import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../src/core/theme/app_colors.dart';
import '../../src/core/theme/app_text_styles.dart';
import '../../src/services/supabase_service.dart';
import '../shopping/list/shopping_list_page.dart';
import '../inventory/dashboard/inventory_dashboard.dart';
import '../events/event_list/event_list_page.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  bool _isLoading = true;

  // Data
  int _shoppingListCount = 0;
  int _lowStockCount = 0;
  List<Map<String, dynamic>> _upcomingEvents = [];
  List<Map<String, dynamic>> _todayTodos = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final householdId = await SupabaseService().getCurrentHouseholdId();
      if (householdId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load all data in parallel
      final results = await Future.wait([
        SupabaseService().getShoppingList(householdId),
        SupabaseService().getLowStockItems(householdId),
        SupabaseService().getUpcomingEvents(householdId),
        SupabaseService().getTodayTodos(),
      ]);

      if (mounted) {
        setState(() {
          _shoppingListCount =
              results[0]
                  .where((item) => !(item['is_checked'] as bool? ?? false))
                  .length;
          _lowStockCount = results[1].length;
          _upcomingEvents = results[2];
          _todayTodos = results[3];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  IconData _getEventIcon(String? title) {
    if (title == null) return Icons.event;
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('doctor') ||
        lowerTitle.contains('hospital') ||
        lowerTitle.contains('appointment')) {
      return Icons.local_hospital;
    }
    if (lowerTitle.contains('soccer') ||
        lowerTitle.contains('sport') ||
        lowerTitle.contains('practice')) {
      return Icons.sports_soccer;
    }
    return Icons.event;
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  Future<void> _toggleTodo(String todoId, bool currentValue) async {
    try {
      await SupabaseService().toggleTodo(todoId, !currentValue);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error updating todo: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top App Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    // Profile Picture
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.5),
                          width: 2,
                        ),
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    // Title
                    Expanded(
                      child: Text(
                        "Dashboard",
                        style: AppTextStyles.headerMedium.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    // Settings Button
                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: AppColors.onSurfaceLight,
                      ),
                      onPressed: () {
                        // TODO: Navigate to settings
                      },
                    ),
                  ],
                ),
              ),

              // Greeting
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  "${_getGreeting()}, Familia!",
                  style: AppTextStyles.headerLarge.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Quick Actions Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: [
                    // Shopping List
                    _QuickActionCard(
                      icon: Icons.shopping_cart,
                      title: "Shopping List",
                      subtitle: "$_shoppingListCount items",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ShoppingListPage(),
                          ),
                        ).then((_) => _loadData());
                      },
                    ),
                    // Finances
                    _QuickActionCard(
                      icon: Icons.account_balance_wallet,
                      title: "Finances",
                      subtitle: "Budget OK",
                      onTap: () {
                        // TODO: Navigate to finances
                      },
                    ),
                    // Inventory
                    _QuickActionCard(
                      icon: Icons.inventory_2,
                      title: "Inventory",
                      subtitle:
                          _lowStockCount > 0
                              ? "$_lowStockCount items low"
                              : "All good",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InventoryDashboard(),
                          ),
                        ).then((_) => _loadData());
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Upcoming Events Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Upcoming Events",
                      style: AppTextStyles.headerMedium.copyWith(fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EventListPage(),
                          ),
                        ).then((_) => _loadData());
                      },
                      child: Text(
                        "View All",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Events List
              if (_upcomingEvents.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "No upcoming events",
                    style: AppTextStyles.bodySmall,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children:
                        _upcomingEvents.take(2).map((event) {
                          final eventDate =
                              event['event_date'] != null
                                  ? DateTime.parse(event['event_date'])
                                  : null;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getEventIcon(event['title']),
                                    color: AppColors.onSurfaceLight,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event['title'] ?? 'Untitled Event',
                                        style: AppTextStyles.cardTitle.copyWith(
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        event['description'] ?? '',
                                        style: AppTextStyles.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (eventDate != null)
                                  Text(
                                    _formatTime(eventDate),
                                    style: AppTextStyles.bodySmall,
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),

              const SizedBox(height: 16),

              // Today's To-Dos Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's To-Dos",
                      style: AppTextStyles.headerMedium.copyWith(fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to todos page
                      },
                      child: Text(
                        "View All",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Todos List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children:
                      _todayTodos.take(3).map((todo) {
                        final isCompleted =
                            todo['is_completed'] as bool? ?? false;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap:
                                    () => _toggleTodo(todo['id'], isCompleted),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(
                                        isCompleted ? 1 : 0.5,
                                      ),
                                      width: 2,
                                    ),
                                    color:
                                        isCompleted
                                            ? AppColors.primary
                                            : Colors.transparent,
                                  ),
                                  child:
                                      isCompleted
                                          ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  todo['title'] ?? 'Untitled Todo',
                                  style: AppTextStyles.bodyRegular.copyWith(
                                    decoration:
                                        isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                    color:
                                        isCompleted
                                            ? AppColors.onSurfaceVariantLight
                                            : AppColors.onSurfaceLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),

              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show add dialog
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
