import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/shared/glass_container.dart';
import '../../../src/shared/custom_text_field.dart';
import '../../../src/services/supabase_service.dart';
import '../category_items/category_items_page.dart';

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

  IconData _getIconForCategory(String? iconName) {
    // Simple mapping for now, could be improved
    switch (iconName) {
      case 'kitchen': return Icons.kitchen;
      case 'toilet': return Icons.bathtub_outlined;
      case 'bedroom': return Icons.bed_outlined;
      case 'living_room': return Icons.weekend_outlined;
      case 'cleaning': return Icons.cleaning_services_outlined;
      default: return Icons.category_outlined;
    }
  }

  Future<void> _showAddCategoryDialog() async {
    if (_householdId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No household found. Please create or join a family first.")),
      );
      return;
    }

    final nameController = TextEditingController();
    String selectedIcon = 'others';
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFFFFF0F3), // Soft pink background
            title: Text("Add Category", style: AppTextStyles.cardTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: "Category Name",
                  hint: "e.g. Garage",
                  controller: nameController,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedIcon,
                  decoration: InputDecoration(
                    labelText: "Icon",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'kitchen', child: Text("Kitchen")),
                    DropdownMenuItem(value: 'toilet', child: Text("Toilet")),
                    DropdownMenuItem(value: 'bedroom', child: Text("Bedroom")),
                    DropdownMenuItem(value: 'living_room', child: Text("Living Room")),
                    DropdownMenuItem(value: 'cleaning', child: Text("Cleaning")),
                    DropdownMenuItem(value: 'others', child: Text("Others")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => selectedIcon = val);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CANCEL", style: TextStyle(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    Navigator.pop(context);
                    // Use the parent's setState to show loading
                    this.setState(() => _isLoading = true);
                    try {
                      await SupabaseService().addCategory(
                        nameController.text.trim(),
                        selectedIcon,
                        _householdId!,
                      );
                      await _loadCategories(); // Refresh list
                    } catch (e) {
                      debugPrint("Error adding category: $e");
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error adding category: $e")),
                        );
                        this.setState(() => _isLoading = false);
                      }
                    }
                  }
                },
                child: const Text("ADD"),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
    }

    // Empty state with refresh button
    if (_categories.isEmpty) {
       return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddCategoryDialog,
          backgroundColor: AppColors.primaryPink,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text("No categories found", style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCategories, // Retry
                child: const Text("Refresh"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: AppColors.primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Inventory", style: AppTextStyles.headerMedium),
            const SizedBox(height: 20),
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
                        Icon(_getIconForCategory(category['icon']), size: 32, color: AppColors.accentPink),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['name'],
                              style: AppTextStyles.cardTitle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "View Items", // Count requires separate query or join
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
