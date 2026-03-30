import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/widgets/roomah_back_app_bar.dart';
import '../../../src/shared/glass_container.dart';
import '../../../src/services/supabase_service.dart';
import '../../../src/shared/inventory_category_lucide_icons.dart';
import '../category_items/category_items_page.dart';
import 'inventory_add_category_bottom_sheet.dart';

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({super.key});

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _householdId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final householdId = await SupabaseService().getCurrentHouseholdId();
      if (householdId == null) {
        // Handle no household case (e.g. redirect to create family)
        setState(() => _isLoading = false);
        return;
      }
      _householdId = householdId;

      final categories = await SupabaseService().getInventoryCategories(householdId);
      
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading categories: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  PreferredSizeWidget _inventoryAppBar(BuildContext context) {
    return roomahSolidBackAppBar(
      context,
      title: 'Stock',
      actions: [
        IconButton(
          onPressed: _showAddCategoryBottomSheet,
          icon: const Icon(LucideIcons.plus),
          tooltip: 'New category',
        ),
      ],
    );
  }

  Future<void> _showAddCategoryBottomSheet() async {
    if (_householdId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "We're not seeing a household yet — create or join a family first.",
          ),
        ),
      );
      return;
    }

    final result = await showInventoryAddCategoryBottomSheet(context);
    if (result == null || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await SupabaseService().addCategory(
        result.name,
        result.iconKey,
        _householdId!,
      );
      await _loadCategories();
    } catch (e) {
      debugPrint("Error adding category: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't add that category — want to try again?"),
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: _inventoryAppBar(context),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primaryPink)),
      );
    }

    // Empty state with refresh button
    if (_categories.isEmpty) {
       return Scaffold(
        appBar: _inventoryAppBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.package, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                "No shelves yet — add your first category when you're ready.",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCategories,
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _inventoryAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryItemsPage(
                          categoryName: category['name'], 
                          categoryId: category['id'],
                          householdId: _householdId!,
                        ),
                      ),
                    );
                  },
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          InventoryCategoryLucideIcons.resolve(category['icon'] as String?),
                          size: 32,
                          color: AppColors.accentPink,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['name'],
                              style: AppTextStyles.cardTitle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Peek inside",
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
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
