import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/shared/format_rupiah.dart';
import '../../../src/services/supabase_service.dart';
import 'edit_item_bottom_sheet.dart';
import 'edit_item_quantity_bottom_sheet.dart';

/// Bottom sheet yang isinya:
/// Row 1: detail item (photo, name, price, qty, status)
/// Row 2: tombol Edit
/// Row 3: tombol Update stock
Future<bool?> showInventoryItemActionsBottomSheet(
  BuildContext context, {
  required String itemId,
  required String householdId,
  required String categoryId,
  required String categoryName,
  required String initialName,
  required String initialBrand,
  required dynamic initialPrice,
  required String initialPurchaseLink,
  required String? initialImageUrl,
  required DateTime? initialPurchaseDate,
  required DateTime? initialExpireDate,
  required int initialQuantity,
  required int initialLowStockThreshold,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _InventoryItemActionsSheetBody(
      itemId: itemId,
      householdId: householdId,
      categoryId: categoryId,
      categoryName: categoryName,
      initialName: initialName,
      initialBrand: initialBrand,
      initialPrice: initialPrice,
      initialPurchaseLink: initialPurchaseLink,
      initialImageUrl: initialImageUrl,
      initialPurchaseDate: initialPurchaseDate,
      initialExpireDate: initialExpireDate,
      initialQuantity: initialQuantity,
      initialLowStockThreshold: initialLowStockThreshold,
    ),
  );
}

class _InventoryItemActionsSheetBody extends StatelessWidget {
  const _InventoryItemActionsSheetBody({
    required this.itemId,
    required this.householdId,
    required this.categoryId,
    required this.categoryName,
    required this.initialName,
    required this.initialBrand,
    required this.initialPrice,
    required this.initialPurchaseLink,
    required this.initialImageUrl,
    required this.initialPurchaseDate,
    required this.initialExpireDate,
    required this.initialQuantity,
    required this.initialLowStockThreshold,
  });

  final String itemId;
  final String householdId;
  final String categoryId;
  final String categoryName;

  final String initialName;
  final String initialBrand;
  final dynamic initialPrice;
  final String initialPurchaseLink;
  final String? initialImageUrl;
  final DateTime? initialPurchaseDate;
  final DateTime? initialExpireDate;
  final int initialQuantity;
  final int initialLowStockThreshold;

  String _statusLabel() {
    if (initialQuantity <= 0) return 'out_of_stock';
    if (initialQuantity <= initialLowStockThreshold) return 'low_stock';
    return 'in_stock';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = initialImageUrl;
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;
    final status = _statusLabel();
    final statusText = status == 'in_stock' ? 'In Stock' : 'Low/Out';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: hasImage
                      ? Image.network(
                          imageUrl!.trim(),
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              width: 72,
                              height: 72,
                              color: Colors.white.withOpacity(0.5),
                              child: const Icon(
                                LucideIcons.imageOff,
                                color: AppColors.textMuted,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 72,
                          height: 72,
                          color: Colors.white.withOpacity(0.5),
                          child: const Icon(
                            LucideIcons.imageOff,
                            color: AppColors.textMuted,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        initialName,
                        style: AppTextStyles.cardTitle,
                      ),
                      if (initialBrand.isNotEmpty)
                        Text(
                          initialBrand,
                          style: AppTextStyles.bodySmall,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        formatRupiah(coerceNum(initialPrice)),
                        style: AppTextStyles.priceText.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Qty: $initialQuantity',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: AppTextStyles.badgeText.copyWith(
                            color: AppColors.accentPink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () async {
                final updated = await showEditInventoryItemBottomSheet(
                  context,
                  itemId: itemId,
                  householdId: householdId,
                  categoryId: categoryId,
                  categoryName: categoryName,
                  initialQuantity: initialQuantity,
                  initialLowStockThreshold: initialLowStockThreshold,
                  initialName: initialName,
                  initialBrand: initialBrand,
                  initialPrice: initialPrice,
                  initialPurchaseLink: initialPurchaseLink,
                  initialImageUrl: initialImageUrl,
                  initialPurchaseDate: initialPurchaseDate,
                  initialExpireDate: initialExpireDate,
                );

                Navigator.pop(context, updated == true);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.textMuted.withOpacity(0.35)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Edit',
                style: AppTextStyles.bodyRegular,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final updated = await showEditInventoryItemQuantityBottomSheet(
                  context,
                  itemId: itemId,
                  householdId: householdId,
                  initialQuantity: initialQuantity,
                  lowStockThreshold: initialLowStockThreshold,
                );
                Navigator.pop(context, updated == true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Update stock',
                style: AppTextStyles.cardTitle.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

