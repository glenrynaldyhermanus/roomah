import 'package:flutter/material.dart';

import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/shared/custom_text_field.dart';
import '../../../src/services/supabase_service.dart';

/// Edit only inventory item `quantity` (stock).
///
/// Rule:
/// - `quantity <= 0` => `out_of_stock`
/// - `quantity <= lowStockThreshold` => `low_stock`
/// - else => `in_stock`
Future<bool?> showEditInventoryItemQuantityBottomSheet(
  BuildContext context, {
  required String itemId,
  required String householdId,
  required int initialQuantity,
  required int lowStockThreshold,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _EditItemQuantitySheetBody(
      itemId: itemId,
      householdId: householdId,
      initialQuantity: initialQuantity,
      lowStockThreshold: lowStockThreshold,
    ),
  );
}

class _EditItemQuantitySheetBody extends StatefulWidget {
  const _EditItemQuantitySheetBody({
    required this.itemId,
    required this.householdId,
    required this.initialQuantity,
    required this.lowStockThreshold,
  });

  final String itemId;
  final String householdId;
  final int initialQuantity;
  final int lowStockThreshold;

  @override
  State<_EditItemQuantitySheetBody> createState() =>
      _EditItemQuantitySheetBodyState();
}

class _EditItemQuantitySheetBodyState
    extends State<_EditItemQuantitySheetBody> {
  late final TextEditingController _quantityController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.initialQuantity.toString(),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  String _statusForQuantity(int q, int lowStockThreshold) {
    if (q <= 0) return 'out_of_stock';
    if (q <= lowStockThreshold) return 'low_stock';
    return 'in_stock';
  }

  int? _parseQuantity(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      final q = _parseQuantity(_quantityController.text);
      if (q == null) throw Exception('Quantity is invalid');

      await SupabaseService().updateInventoryItem(
        itemId: widget.itemId,
        householdId: widget.householdId,
        updateData: {
          'quantity': q,
          'status': _statusForQuantity(q, widget.lowStockThreshold),
        },
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              Text(
                'Edit stock / quantity',
                style: AppTextStyles.headerMedium.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Quantity',
                hint: 'e.g. 10',
                keyboardType: TextInputType.number,
                controller: _quantityController,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save stock changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

