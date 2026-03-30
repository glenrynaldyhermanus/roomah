import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../src/core/theme/app_colors.dart';
import '../../src/core/theme/app_text_styles.dart';
import '../../src/services/supabase_service.dart';
import '../notes/notes_page.dart';
import '../shopping/list/shopping_list_page.dart';
import '../shopping/stores/stores_page.dart';
import '../inventory/dashboard/inventory_dashboard.dart';
import '../guides/guide_detail_page.dart';
import '../guides/guides_list_page.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key, required this.onOpenCalendar});

  /// Switches main shell to the Calendar tab.
  final VoidCallback onOpenCalendar;

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  bool _isLoading = true;

  // Data
  int _shoppingListCount = 0;
  int _lowStockCount = 0;
  int _totalPoints = 0;
  List<Map<String, dynamic>> _upcomingEvents = [];
  List<Map<String, dynamic>> _todayTodos = [];
  List<Map<String, dynamic>> _dueRoutines = [];

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
        SupabaseService().getMyTotalPoints(householdId),
        SupabaseService().getRoutinesDueForHousehold(householdId),
      ]);

      if (mounted) {
        final shoppingList = results[0] as List<Map<String, dynamic>>;
        final lowStock = results[1] as List<Map<String, dynamic>>;
        final upcoming = results[2] as List<Map<String, dynamic>>;
        final todos = results[3] as List<Map<String, dynamic>>;
        final points = results[4] as int;
        final dueRoutines = results[5] as List<Map<String, dynamic>>;

        setState(() {
          _shoppingListCount =
              shoppingList
                  .where((item) => !(item['is_checked'] as bool? ?? false))
                  .length;
          _lowStockCount = lowStock.length;
          _upcomingEvents = upcoming;
          _todayTodos = todos;
          _totalPoints = points;
          _dueRoutines = dueRoutines;
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
    if (hour < 12) return "Morning, Teman SeRoomah!";
    if (hour < 17) return "Afternoon, Teman SeRoomah!";
    return "Evening, Teman SeRoomah!";
  }

  IconData _getEventIcon(String? title) {
    if (title == null) return LucideIcons.calendar;
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('doctor') ||
        lowerTitle.contains('hospital') ||
        lowerTitle.contains('appointment')) {
      return LucideIcons.hospital;
    }
    if (lowerTitle.contains('soccer') ||
        lowerTitle.contains('sport') ||
        lowerTitle.contains('practice')) {
      return LucideIcons.trophy;
    }
    return LucideIcons.calendar;
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  Future<void> _toggleTodo(String todoId, bool currentValue) async {
    try {
      await SupabaseService().toggleTodo(todoId, !currentValue);
      _loadData();
    } catch (e) {
      debugPrint("Error updating todo: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't update that — want to try again?"),
          ),
        );
      }
    }
  }

  void _openRoutineSheet(Map<String, dynamic> routine) {
    final title = routine['title'] as String? ?? 'No title yet';
    final due = routine['next_due_date'] as String?;
    final nested = routine['guides'];
    final guideId =
        nested is Map<String, dynamic> ? nested['id'] as String? : null;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: AppTextStyles.cardTitle),
                if (due != null) ...[
                  const SizedBox(height: 8),
                  Text('Next run: $due', style: AppTextStyles.bodySmall),
                ],
                const SizedBox(height: 20),
                if (guideId != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GuideDetailPage(guideId: guideId),
                        ),
                      ).then((_) => _loadData());
                    },
                    icon: const Icon(LucideIcons.bookOpen),
                    label: const Text('Guide'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  Text(
                    'No guide linked yet — open Guides → Routines and attach one so I can walk you through next time.',
                    style: AppTextStyles.bodySmall,
                  ),
              ],
            ),
          ),
        );
      },
    );
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
                      child: const Icon(
                        LucideIcons.user,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title
                    Expanded(
                      child: Text(
                        "Home",
                        style: AppTextStyles.headerMedium,
                      ),
                    ),
                    // Settings Button
                    IconButton(
                      icon: const Icon(
                        LucideIcons.settings,
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
                  _getGreeting(),
                  style: AppTextStyles.headerLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.award,
                      size: 22,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "You've got $_totalPoints pts",
                      style: AppTextStyles.bodyRegular.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceLight,
                      ),
                    ),
                  ],
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
                  childAspectRatio: 0.62,
                  children: [
                    // Shopping List
                    _QuickActionCard(
                      icon: LucideIcons.shoppingCart,
                      title: "Shopping",
                      subtitle:
                          _shoppingListCount > 0
                              ? "$_shoppingListCount waiting for you"
                              : "Nothing queued",
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
                      icon: LucideIcons.wallet,
                      title: "Money",
                      subtitle: "All quiet on your budget",
                      onTap: () {
                        // TODO: Navigate to finances
                      },
                    ),
                    // Inventory
                    _QuickActionCard(
                      icon: LucideIcons.package,
                      title: "Stock",
                      subtitle:
                          _lowStockCount > 0
                              ? "$_lowStockCount need a top-up"
                              : "You're stocked",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InventoryDashboard(),
                          ),
                        ).then((_) => _loadData());
                      },
                    ),
                    _QuickActionCard(
                      icon: LucideIcons.store,
                      title: "Stores",
                      subtitle: "Your go-to shops & chats",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StoresPage()),
                        ).then((_) => _loadData());
                      },
                    ),
                    _QuickActionCard(
                      icon: LucideIcons.stickyNote,
                      title: "Notes",
                      subtitle: "Leave the crew a note",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotesPage()),
                        ).then((_) => _loadData());
                      },
                    ),
                    _QuickActionCard(
                      icon: LucideIcons.bookOpen,
                      title: "Guides",
                      subtitle:
                          "${_dueRoutines.length} routine${_dueRoutines.length == 1 ? '' : 's'} want attention",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GuidesListPage(),
                          ),
                        ).then((_) => _loadData());
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (_dueRoutines.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Routines",
                        style: AppTextStyles.headerMedium.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${_dueRoutines.length}",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children:
                        _dueRoutines.take(5).map((routine) {
                          final title =
                              routine['title'] as String? ?? 'No title yet';
                          final due = routine['next_due_date'] as String?;
                          final nested = routine['guides'];
                          final hasGuide =
                              nested is Map<String, dynamic> &&
                              nested['id'] != null;
                          return GestureDetector(
                            onTap: () => _openRoutineSheet(routine),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.15),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.refreshCw,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: AppTextStyles.cardTitle
                                              .copyWith(fontSize: 15),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (due != null)
                                          Text(
                                            "Let's tackle by $due",
                                            style: AppTextStyles.bodySmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (hasGuide)
                                    Icon(
                                      LucideIcons.bookOpen,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
              ],

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
                      "Upcoming",
                      style: AppTextStyles.headerMedium.copyWith(fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onOpenCalendar();
                        _loadData();
                      },
                      child: Text(
                        "More",
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
                    "Calendar's clear — enjoy the breather.",
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
                                        event['title'] ?? 'No title yet',
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
                      "Today",
                      style: AppTextStyles.headerMedium.copyWith(fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to todos page
                      },
                      child: Text(
                        "More",
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
                                            LucideIcons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  todo['title'] ?? 'No title yet',
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
        child: const Icon(LucideIcons.plus, color: Colors.white),
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
        padding: const EdgeInsets.all(10),
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
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
