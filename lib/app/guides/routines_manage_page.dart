import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../src/core/theme/app_colors.dart';
import '../../src/core/theme/app_text_styles.dart';
import '../../src/widgets/roomah_back_app_bar.dart';
import '../../src/services/supabase_service.dart';
import 'guide_detail_page.dart';

class RoutinesManagePage extends StatefulWidget {
  const RoutinesManagePage({super.key, required this.householdId});

  final String householdId;

  @override
  State<RoutinesManagePage> createState() => _RoutinesManagePageState();
}

class _RoutinesManagePageState extends State<RoutinesManagePage> {
  bool _loading = true;
  List<Map<String, dynamic>> _routines = [];
  List<Map<String, dynamic>> _guides = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        SupabaseService().getRoutinesForHousehold(widget.householdId),
        SupabaseService().getGuides(widget.householdId),
      ]);
      if (mounted) {
        setState(() {
          _routines = results[0];
          _guides = results[1];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _changeGuide(Map<String, dynamic> routine) async {
    final rid = routine['id'] as String?;
    if (rid == null) return;

    final nested = routine['guides'];
    String? currentGuideId;
    if (nested is Map<String, dynamic>) {
      currentGuideId = nested['id'] as String?;
    }

    final selected = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Link guide', style: AppTextStyles.cardTitle),
              ),
              ListTile(
                leading: const Icon(LucideIcons.circleX),
                title: Text('No guide', style: AppTextStyles.bodyRegular),
                onTap: () => Navigator.pop(ctx, ''),
              ),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  itemCount: _guides.length,
                  itemBuilder: (context, i) {
                    final g = _guides[i];
                    final gid = g['id'] as String?;
                    final title = g['title'] as String? ?? '';
                    return ListTile(
                      leading: const Icon(LucideIcons.bookOpen),
                      title: Text(title, style: AppTextStyles.bodyRegular),
                      trailing:
                          gid == currentGuideId
                              ? Icon(LucideIcons.check, color: AppColors.primary)
                              : null,
                      onTap: () => Navigator.pop(ctx, gid),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null || !mounted) return;
    final newGuideId = selected.isEmpty ? null : selected;
    try {
      await SupabaseService().updateRoutineGuideId(
        routineId: rid,
        householdId: widget.householdId,
        guideId: newGuideId,
      );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  String? _guideTitleFromRoutine(Map<String, dynamic> routine) {
    final nested = routine['guides'];
    if (nested is Map<String, dynamic>) {
      return nested['title'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: roomahSolidBackAppBar(context, title: 'Routines'),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _routines.length,
                itemBuilder: (context, i) {
                  final r = _routines[i];
                  final title = r['title'] as String? ?? 'Routine';
                  final due = r['next_due_date'] as String?;
                  final guideTitle = _guideTitleFromRoutine(r);
                  final guideNested = r['guides'];
                  final guideId = guideNested is Map<String, dynamic> ? guideNested['id'] as String? : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _changeGuide(r),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                                    ),
                                  ),
                                  if (guideId != null)
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => GuideDetailPage(guideId: guideId),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Guide',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (due != null)
                                Text(
                                  'Next due: $due',
                                  style: AppTextStyles.bodySmall,
                                ),
                              const SizedBox(height: 6),
                              Text(
                                guideTitle != null ? 'Guide: $guideTitle' : 'Guide: — tap to link',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariantLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
