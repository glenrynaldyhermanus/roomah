import 'package:flutter/material.dart';
import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/shared/glass_container.dart';
import '../../../src/services/supabase_service.dart';
import '../add_item/add_item_page.dart';

class CategoryItemsPage extends StatefulWidget {
  final String categoryName;
  final String categoryId;
  final String householdId;

  const CategoryItemsPage({
    super.key, 
    required this.categoryName,
    required this.categoryId,
    required this.householdId,
  });

  @override
  State<CategoryItemsPage> createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await SupabaseService().getInventoryItems(widget.householdId, widget.categoryId);
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading items: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.categoryName, style: AppTextStyles.cardTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accentPink),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddItemPage(
                    categoryName: widget.categoryName,
                    categoryId: widget.categoryId,
                    householdId: widget.householdId,
                  ),
                ),
              );
              _loadItems(); // Refresh after adding
            },
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
          : _items.isEmpty 
              ? Center(child: Text("No items yet", style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textMuted)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'] ?? 'Unknown', style: AppTextStyles.cardTitle),
                                  if (item['brand'] != null)
                                    Text(item['brand'], style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (item['price'] != null)
                                  Text("\$${item['price']}", style: AppTextStyles.priceText.copyWith(fontSize: 16)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentPink.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['status'] == 'in_stock' ? "In Stock" : "Low/Out",
                                    style: AppTextStyles.badgeText.copyWith(color: AppColors.accentPink),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
