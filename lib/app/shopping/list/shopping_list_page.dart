import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/widgets/roomah_back_app_bar.dart';
import '../../../src/shared/glass_container.dart';
import '../../../src/services/supabase_service.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _items = [];
  String? _householdId;
  final _addItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _addItemController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final householdId = await SupabaseService().getCurrentHouseholdId();
      if (householdId != null) {
        _householdId = householdId;
        final items = await SupabaseService().getShoppingList(householdId);
        setState(() {
          _items = items;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading shopping list: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAddItem() async {
    if (_addItemController.text.isEmpty || _householdId == null) return;

    try {
      await SupabaseService().addShoppingItem(_addItemController.text.trim(), _householdId!);
      _addItemController.clear();
      _loadItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding item: $e")),
        );
      }
    }
  }

  Future<void> _handleToggleItem(String itemId, bool currentValue) async {
    try {
      // Optimistic update
      setState(() {
        final index = _items.indexWhere((item) => item['id'] == itemId);
        if (index != -1) {
          _items[index]['is_checked'] = !currentValue;
        }
      });
      await SupabaseService().toggleShoppingItem(itemId, !currentValue);
    } catch (e) {
      _loadItems(); // Revert on error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating item: $e")),
        );
      }
    }
  }

  Future<void> _handleDeleteItem(String itemId) async {
    try {
      await SupabaseService().deleteShoppingItem(itemId);
      _loadItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting item: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: roomahSolidBackAppBar(context, title: 'Shopping List'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  
                  // Add Item Input
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _addItemController,
                            decoration: const InputDecoration(
                              hintText: "Add item...",
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _handleAddItem(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.plusCircle, color: AppColors.primaryPink),
                          onPressed: _handleAddItem,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_items.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text("Your list is empty", style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textMuted)),
                      ),
                    )
                  else
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final isChecked = item['is_checked'] as bool;
                          
                          return Dismissible(
                            key: Key(item['id']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red.withOpacity(0.8),
                              child: const Icon(LucideIcons.trash2, color: Colors.white),
                            ),
                            onDismissed: (_) => _handleDeleteItem(item['id']),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    activeColor: AppColors.primaryPink,
                                    onChanged: (val) => _handleToggleItem(item['id'], isChecked),
                                  ),
                                  Expanded(
                                    child: Text(
                                      item['name'], 
                                      style: isChecked 
                                          ? AppTextStyles.bodyRegular.copyWith(decoration: TextDecoration.lineThrough, color: AppColors.textMuted)
                                          : AppTextStyles.bodyRegular,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
