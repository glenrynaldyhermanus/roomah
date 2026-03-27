import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/shared/glass_container.dart';
import '../../../src/services/supabase_service.dart';
import '../add_event/add_event_page.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _events = [];
  String? _householdId;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final householdId = await SupabaseService().getCurrentHouseholdId();
      if (householdId != null) {
        _householdId = householdId;
        final events = await SupabaseService().getEvents(householdId);
        setState(() {
          _events = events;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading events: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_householdId == null) return;
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEventPage(householdId: _householdId!)),
          );
          _loadEvents(); // Refresh list after adding
        },
        backgroundColor: AppColors.primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Upcoming Events", style: AppTextStyles.headerMedium),
                  const SizedBox(height: 20),
                  if (_events.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text("No events yet", style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textMuted)),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        final date = DateTime.parse(event['event_date']);
                        final day = date.day;
                        final month = DateFormat('MMM').format(date).toUpperCase();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryPink.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(month, style: AppTextStyles.badgeText.copyWith(color: AppColors.primaryPink)),
                                      Text("$day", style: AppTextStyles.headerMedium.copyWith(fontSize: 20)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(event['title'], style: AppTextStyles.cardTitle),
                                      const SizedBox(height: 4),
                                      if (event['frequency_type'] != null)
                                        Row(
                                          children: [
                                            const Icon(Icons.repeat, size: 14, color: AppColors.textMuted),
                                            const SizedBox(width: 4),
                                            Text(event['frequency_type'], style: AppTextStyles.bodySmall),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
                                  onPressed: () async {
                                    await SupabaseService().deleteEvent(event['id']);
                                    _loadEvents();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
