import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../src/core/theme/app_colors.dart';
import '../../src/core/theme/app_text_styles.dart';
import '../../src/widgets/roomah_back_app_bar.dart';
import '../../src/services/supabase_service.dart';
import 'guide_detail_page.dart';
import 'guide_editor_page.dart';
import 'routines_manage_page.dart';

class GuidesListPage extends StatefulWidget {
  const GuidesListPage({super.key});

  @override
  State<GuidesListPage> createState() => _GuidesListPageState();
}

class _GuidesListPageState extends State<GuidesListPage> {
  bool _loading = true;
  String? _householdId;
  List<Map<String, dynamic>> _guides = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final hid = await SupabaseService().getCurrentHouseholdId();
      if (hid == null || !mounted) {
        setState(() => _loading = false);
        return;
      }
      _householdId = hid;
      final list = await SupabaseService().getGuides(hid);
      if (mounted) {
        setState(() {
          _guides = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> g) async {
    final id = g['id'] as String?;
    final title = g['title'] as String? ?? 'Guide';
    if (id == null || _householdId == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Delete?', style: AppTextStyles.cardTitle),
            content: Text(
              'Remove “$title”? This cannot be undone.',
              style: AppTextStyles.bodyRegular,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: AppTextStyles.bodyRegular),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete', style: AppTextStyles.bodyRegular.copyWith(color: AppColors.accentPink)),
              ),
            ],
          ),
    );
    if (ok != true || !mounted) return;
    try {
      await SupabaseService().deleteGuide(id, _householdId!);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: roomahSolidBackAppBar(
        context,
        title: 'Guides',
        actions: [
          TextButton(
            onPressed:
                _householdId == null
                    ? null
                    : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoutinesManagePage(householdId: _householdId!),
                        ),
                      );
                    },
            child: Text(
              'Routines',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _guides.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No guides yet. Add a household SOP (e.g. mop the floor, clean the bathroom).',
                    style: AppTextStyles.bodyRegular,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                itemCount: _guides.length,
                itemBuilder: (context, i) {
                  final g = _guides[i];
                  final title = g['title'] as String? ?? 'Untitled';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GuideDetailPage(guideId: g['id'] as String),
                            ),
                          ).then((_) => _load());
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  LucideIcons.bookOpen,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  title,
                                  style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.pencil, color: AppColors.onSurfaceLight),
                                onPressed:
                                    _householdId == null
                                        ? null
                                        : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => GuideEditorPage(
                                                    householdId: _householdId!,
                                                    guideId: g['id'] as String,
                                                  ),
                                            ),
                                          ).then((_) => _load());
                                        },
                              ),
                              IconButton(
                                icon: Icon(LucideIcons.trash2, color: AppColors.accentPink.withOpacity(0.9)),
                                onPressed: () => _confirmDelete(g),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _householdId == null
                ? null
                : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GuideEditorPage(householdId: _householdId!),
                    ),
                  ).then((_) => _load());
                },
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }
}
