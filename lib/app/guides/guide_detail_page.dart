import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../src/core/theme/app_colors.dart';
import '../../src/core/theme/app_text_styles.dart';
import '../../src/widgets/roomah_back_app_bar.dart';
import '../../src/shared/glass_container.dart';
import '../../src/services/supabase_service.dart';
import 'guide_editor_page.dart';

class GuideDetailPage extends StatefulWidget {
  const GuideDetailPage({super.key, required this.guideId});

  final String guideId;

  @override
  State<GuideDetailPage> createState() => _GuideDetailPageState();
}

List<String> _parseSteps(dynamic steps) {
  if (steps == null) return [];
  if (steps is List) {
    return steps.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
  }
  return [];
}

bool _inventoryRowInStock(Map<String, dynamic> inv) {
  final st = inv['status'] as String? ?? 'in_stock';
  if (st == 'out_of_stock') return false;
  final q = inv['quantity'];
  if (q is int) return q > 0;
  if (q is num) return q > 0;
  return true;
}

int _inventorySumForCatalogName(String catalogName, List<Map<String, dynamic>> inventory) {
  final target = catalogName.trim().toLowerCase();
  var sum = 0;
  for (final inv in inventory) {
    final n = (inv['name'] as String?)?.trim().toLowerCase() ?? '';
    if (n != target) continue;
    if (!_inventoryRowInStock(inv)) continue;
    final q = inv['quantity'];
    if (q is int) {
      sum += q;
    } else if (q is num) {
      sum += q.toInt();
    } else {
      sum += 1;
    }
  }
  return sum;
}

class _GuideDetailPageState extends State<GuideDetailPage> {
  bool _loading = true;
  Map<String, dynamic>? _guide;
  List<Map<String, dynamic>> _inventory = [];
  String? _householdId;

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
      final results = await Future.wait([
        SupabaseService().getGuideById(widget.guideId, hid),
        SupabaseService().getInventoryItemsForHousehold(hid),
      ]);
      if (mounted) {
        setState(() {
          _guide = results[0] as Map<String, dynamic>?;
          _inventory = results[1] as List<Map<String, dynamic>>;
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

  Future<void> _addToShopping(String catalogItemId) async {
    try {
      await SupabaseService().addCatalogItemToShoppingList(catalogItemId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to shopping list')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: roomahSolidBackAppBar(context, title: ''),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final g = _guide;
    if (g == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: roomahSolidBackAppBar(context, title: ''),
        body: Center(child: Text('Guide not found', style: AppTextStyles.bodyRegular)),
      );
    }

    final title = g['title'] as String? ?? 'Guide';
    final description = g['description'] as String?;
    final steps = _parseSteps(g['steps']);
    final rawItems = g['guide_items'];
    final guideItems =
        rawItems is List
            ? rawItems.cast<Map<String, dynamic>>()
            : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: roomahSolidBackAppBar(
        context,
        title: title,
        actions: [
          if (_householdId != null)
            IconButton(
              icon: const Icon(LucideIcons.pencil),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => GuideEditorPage(
                          householdId: _householdId!,
                          guideId: widget.guideId,
                        ),
                  ),
                );
                _load();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (description != null && description.isNotEmpty) ...[
              Text(description, style: AppTextStyles.bodyRegular),
              const SizedBox(height: 20),
            ],
            if (guideItems.isNotEmpty) ...[
              Text('What you need', style: AppTextStyles.cardTitle),
              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children:
                      guideItems.map((row) {
                        final nested = row['items'];
                        final itemMap = nested is Map<String, dynamic> ? nested : null;
                        final name = itemMap?['name'] as String? ?? 'Item';
                        final catalogId = row['item_id'] as String?;
                        final notes = row['notes'] as String?;
                        final optional = row['is_optional'] as bool? ?? false;
                        final qty = catalogId != null && itemMap != null
                            ? _inventorySumForCatalogName(name, _inventory)
                            : 0;
                        final hasStock = qty > 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                hasStock ? LucideIcons.circleCheck : LucideIcons.circleX,
                                color: hasStock ? Colors.green.shade700 : AppColors.accentPink,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: name,
                                            style: AppTextStyles.bodyRegular.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (optional)
                                            TextSpan(
                                              text: ' (optional)',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (notes != null && notes.isNotEmpty)
                                      Text(notes, style: AppTextStyles.bodySmall),
                                    if (hasStock)
                                      Text(
                                        'In stock · qty $qty',
                                        style: AppTextStyles.bodySmall.copyWith(color: Colors.green.shade800),
                                      )
                                    else if (catalogId != null)
                                      TextButton.icon(
                                        onPressed: () => _addToShopping(catalogId),
                                        icon: const Icon(LucideIcons.shoppingCart, size: 18),
                                        label: const Text('Add to shopping list'),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          foregroundColor: AppColors.primary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text('Steps', style: AppTextStyles.cardTitle),
            const SizedBox(height: 12),
            if (steps.isEmpty)
              Text(
                'No steps yet. Edit this guide to add instructions.',
                style: AppTextStyles.bodySmall,
              )
            else
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < steps.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${i + 1}',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(steps[i], style: AppTextStyles.bodyRegular)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
