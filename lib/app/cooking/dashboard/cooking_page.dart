import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/widgets/roomah_nav_tab_title_block.dart';
import '../../../src/services/supabase_service.dart';
import '../../../src/shared/glass_container.dart';
import '../recipe_edit_page.dart';
import '../recipe_suggestion/recipe_suggestion_page.dart';

class CookingPage extends StatefulWidget {
  const CookingPage({super.key});

  @override
  State<CookingPage> createState() => _CookingPageState();
}

class _CookingPageState extends State<CookingPage> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _recipes = [];
  bool _loading = true;
  String? _householdId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final hid = await SupabaseService().getCurrentHouseholdId();
      if (hid == null || !mounted) {
        setState(() {
          _householdId = null;
          _recipes = [];
          _loading = false;
        });
        return;
      }
      _householdId = hid;
      final list = await SupabaseService().getRecipes(hid);
      if (mounted) {
        setState(() {
          _recipes = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading recipes: $e')));
      }
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _recipes;
    return _recipes.where((r) {
      final title = (r['title'] as String? ?? '').toLowerCase();
      final desc = (r['description'] as String? ?? '').toLowerCase();
      return title.contains(q) || desc.contains(q);
    }).toList();
  }

  String _subtitle(Map<String, dynamic> r) {
    final prep = r['prep_time_minutes'];
    if (prep is int && prep > 0) return '$prep min';
    if (prep is num && prep > 0) return '${prep.toInt()} min';
    final d = r['description'] as String?;
    if (d != null && d.trim().isNotEmpty) {
      return d.length > 48 ? '${d.substring(0, 48)}…' : d;
    }
    return 'Tap to edit';
  }

  Future<void> _openEditor({Map<String, dynamic>? existing}) async {
    final hid = _householdId;
    if (hid == null) return;
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeEditPage(householdId: hid, existing: existing),
      ),
    );
    if (ok == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      floatingActionButton: FloatingActionButton(
        onPressed: _householdId == null ? null : () => _openEditor(),
        backgroundColor: AppColors.accentPink,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: SafeArea(
        child:
            _loading
                ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryPink,
                  ),
                )
                : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: RoomahNavTabTitleBlock.scrollPadding,
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const RoomahNavTabTitleBlock(title: 'Cooking'),
                            GlassContainer(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (_) => setState(() {}),
                                style: AppTextStyles.bodyRegular,
                                decoration: InputDecoration(
                                  hintText: 'Search recipes…',
                                  hintStyle: AppTextStyles.bodySmall,
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    LucideIcons.search,
                                    color: AppColors.primary.withOpacity(0.7),
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => const RecipeSuggestionPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  LucideIcons.sparkles,
                                  color: AppColors.accentPink,
                                  size: 20,
                                ),
                                label: Text(
                                  'Suggest recipes (AI)',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.accentPink,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.accentPink,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_householdId == null)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'Join or create a household to add recipes.',
                            style: AppTextStyles.bodyRegular.copyWith(
                              color: AppColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else if (_filtered.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            _recipes.isEmpty
                                ? 'No recipes yet. Tap + to add one.'
                                : 'No matches for your search.',
                            style: AppTextStyles.bodyRegular.copyWith(
                              color: AppColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.92,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final r = _filtered[index];
                            final title = r['title'] as String? ?? 'Recipe';
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _openEditor(existing: r),
                                child: GlassContainer(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        LucideIcons.utensilsCrossed,
                                        color: AppColors.accentPink,
                                        size: 28,
                                      ),
                                      const Spacer(),
                                      Text(
                                        title,
                                        style: AppTextStyles.cardTitle.copyWith(
                                          fontSize: 15,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _subtitle(r),
                                        style: AppTextStyles.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }, childCount: _filtered.length),
                        ),
                      ),
                  ],
                ),
      ),
    );
  }
}
