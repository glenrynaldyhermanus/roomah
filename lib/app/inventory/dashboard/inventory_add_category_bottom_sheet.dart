import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/shared/custom_text_field.dart';
import '../../../src/shared/inventory_category_lucide_icons.dart';

/// Shows add-category form and nested Lucide icon picker.
Future<({String name, String iconKey})?> showInventoryAddCategoryBottomSheet(
  BuildContext context,
) {
  return showModalBottomSheet<({String name, String iconKey})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _AddCategorySheetBody(),
  );
}

class _AddCategorySheetBody extends StatefulWidget {
  const _AddCategorySheetBody();

  @override
  State<_AddCategorySheetBody> createState() => _AddCategorySheetBodyState();
}

class _AddCategorySheetBodyState extends State<_AddCategorySheetBody> {
  final _nameController = TextEditingController();
  String _iconKey = 'package';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _openIconPicker() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _LucideIconPickerSheet(
        selectedKey: _iconKey,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _iconKey = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Add category', style: AppTextStyles.headerMedium.copyWith(fontSize: 20)),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Category name',
                hint: 'e.g. Garage',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              Text('Icon', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Material(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _openIconPicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(
                          InventoryCategoryLucideIcons.resolve(_iconKey),
                          size: 28,
                          color: AppColors.accentPink,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Choose icon',
                            style: AppTextStyles.bodyRegular,
                          ),
                        ),
                        Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) return;
                  Navigator.pop(context, (name: name, iconKey: _iconKey));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Add category', style: AppTextStyles.cardTitle.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LucideIconPickerSheet extends StatefulWidget {
  const _LucideIconPickerSheet({required this.selectedKey});

  final String selectedKey;

  @override
  State<_LucideIconPickerSheet> createState() => _LucideIconPickerSheetState();
}

class _LucideIconPickerSheetState extends State<_LucideIconPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = InventoryCategoryLucideIcons.pickerEntries
        .where((e) => e.key.toLowerCase().contains(_query))
        .toList();
    final height = MediaQuery.sizeOf(context).height * 0.72;

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('Pick icon', style: AppTextStyles.headerMedium.copyWith(fontSize: 18)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(LucideIcons.x, color: AppColors.textDark),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search icons…',
                filled: true,
                fillColor: Colors.white.withOpacity(0.55),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(LucideIcons.search, size: 20, color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final e = entries[index];
                final selected = e.key == widget.selectedKey;
                return Material(
                  color: selected
                      ? AppColors.primaryPink.withOpacity(0.15)
                      : Colors.white.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => Navigator.pop(context, e.key),
                    borderRadius: BorderRadius.circular(12),
                    child: Icon(
                      e.icon,
                      size: 24,
                      color: selected ? AppColors.primaryPink : AppColors.textDark,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
