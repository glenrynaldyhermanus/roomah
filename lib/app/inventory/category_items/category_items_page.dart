import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/widgets/roomah_back_app_bar.dart';
import '../../../src/shared/glass_container.dart';
import '../../../src/services/supabase_service.dart';
import '../../../src/shared/format_rupiah.dart';
import '../add_item/add_item_bottom_sheet.dart';
import '../add_item/edit_item_bottom_sheet.dart';
import '../add_item/edit_item_quantity_bottom_sheet.dart';
import '../add_item/inventory_item_actions_bottom_sheet.dart';

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

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Widget _itemImagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(LucideIcons.imageOff, color: AppColors.textMuted),
    );
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

  Future<void> _openItemActions(Map<String, dynamic> item) async {
    final itemId = item['id']?.toString();
    if (itemId == null) return;

    final lowStockThreshold =
        item['low_stock_threshold'] == null ? 3 : _parseInt(item['low_stock_threshold']);

    final updated = await showInventoryItemActionsBottomSheet(
      context,
      itemId: itemId,
      householdId: widget.householdId,
      categoryId: widget.categoryId,
      categoryName: widget.categoryName,
      initialName: item['name']?.toString() ?? '',
      initialBrand: item['brand']?.toString() ?? '',
      initialPrice: item['price'],
      initialPurchaseLink: item['purchase_link']?.toString() ?? '',
      initialImageUrl: item['image_url']?.toString(),
      initialPurchaseDate: _parseDate(item['purchase_date']),
      initialExpireDate: _parseDate(item['expire_date']),
      initialQuantity: _parseInt(item['quantity']),
      initialLowStockThreshold: lowStockThreshold,
    );

    if (updated == true) {
      if (!mounted) return;
      await _loadItems();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated!')),
      );
    }
  }

  Future<void> _openEditItem(Map<String, dynamic> item) async {
    final itemId = item['id']?.toString();
    if (itemId == null) return;

    final initialQuantity = _parseInt(item['quantity']);
    final initialLowStockThreshold =
        item['low_stock_threshold'] == null ? 3 : _parseInt(item['low_stock_threshold']);

    final updated = await showEditInventoryItemBottomSheet(
      context,
      itemId: itemId,
      householdId: widget.householdId,
      categoryId: widget.categoryId,
      categoryName: widget.categoryName,
      initialQuantity: initialQuantity,
      initialLowStockThreshold: initialLowStockThreshold,
      initialName: item['name']?.toString() ?? '',
      initialBrand: item['brand']?.toString() ?? '',
      initialPrice: item['price'],
      initialPurchaseLink: item['purchase_link']?.toString() ?? '',
      initialImageUrl: item['image_url']?.toString(),
      initialPurchaseDate: _parseDate(item['purchase_date']),
      initialExpireDate: _parseDate(item['expire_date']),
    );

    if (updated == true) {
      if (!mounted || !context.mounted) return;
      await _loadItems();
      if (!mounted || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated!')),
      );
    }
  }

  Future<void> _openEditStock(Map<String, dynamic> item) async {
    final itemId = item['id']?.toString();
    if (itemId == null) return;

    final initialQuantity = _parseInt(item['quantity']);
    final lowStockThreshold =
        item['low_stock_threshold'] == null ? 3 : _parseInt(item['low_stock_threshold']);

    final updated = await showEditInventoryItemQuantityBottomSheet(
      context,
      itemId: itemId,
      householdId: widget.householdId,
      initialQuantity: initialQuantity,
      lowStockThreshold: lowStockThreshold,
    );

    if (updated == true) {
      if (!mounted || !context.mounted) return;
      await _loadItems();
      if (!mounted || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: roomahSolidBackAppBar(
        context,
        title: widget.categoryName,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () async {
              final added = await showAddInventoryItemBottomSheet(
                context,
                categoryName: widget.categoryName,
                categoryId: widget.categoryId,
                householdId: widget.householdId,
              );
              if (added != true || !context.mounted) return;
              await _loadItems();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item added successfully!')),
              );
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
                    final imageUrl = item['image_url'] as String?;
                    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            InkWell(
                              onTap: () => _openItemActions(item),
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: hasImage
                                        ? Image.network(
                                            imageUrl.trim(),
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (_, child, progress) {
                                              if (progress == null) return child;
                                              return SizedBox(
                                                width: 60,
                                                height: 60,
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: AppColors.primaryPink,
                                                      value: progress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? progress
                                                                  .cumulativeBytesLoaded /
                                                              progress.expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (_, __, ___) =>
                                                _itemImagePlaceholder(),
                                          )
                                        : _itemImagePlaceholder(),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] ?? 'Unknown',
                                          style: AppTextStyles.cardTitle,
                                        ),
                                        if (item['brand'] != null)
                                          Text(item['brand'],
                                              style: AppTextStyles.bodySmall),
                                        if (item['purchase_date'] != null)
                                          Text(
                                            'Purchase: ${item['purchase_date']}',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        if (item['expire_date'] != null)
                                          Text(
                                            'Expire: ${item['expire_date']}',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.accentPink,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      if (item['price'] != null)
                                        Text(
                                          formatRupiah(coerceNum(item['price'])),
                                          style: AppTextStyles.priceText
                                              .copyWith(fontSize: 16),
                                        ),
                                      if (item['quantity'] != null)
                                        Text(
                                          'Qty: ${_parseInt(item['quantity'])}',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentPink
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item['status'] == 'in_stock'
                                              ? 'In Stock'
                                              : 'Low/Out',
                                          style: AppTextStyles.badgeText
                                              .copyWith(
                                            color: AppColors.accentPink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Row 2 & 3 (Edit + Update stock) are inside the bottom sheet.
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _InventorySwipeRow extends StatefulWidget {
  const _InventorySwipeRow({
    required this.child,
    required this.onEditItem,
    required this.onEditStock,
  });

  final Widget child;
  final Future<void> Function() onEditItem;
  final Future<void> Function() onEditStock;

  @override
  State<_InventorySwipeRow> createState() => _InventorySwipeRowState();
}

class _InventorySwipeRowState extends State<_InventorySwipeRow> {
  static const double actionWidth = 110;
  final double _maxExtent = actionWidth * 2;
  double _extent = 0;

  Future<void> _handleEditItem() async {
    setState(() => _extent = 0);
    await widget.onEditItem();
  }

  Future<void> _handleEditStock() async {
    setState(() => _extent = 0);
    await widget.onEditStock();
  }

  @override
  Widget build(BuildContext context) {
    final bool editVisible = _extent > actionWidth * 0.6;
    final bool stockVisible = _extent > actionWidth * 1.0;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) {
        final dx = details.primaryDelta ?? details.delta.dx;
        if (dx == 0) return;
        setState(() {
          _extent = (_extent - dx).clamp(0, _maxExtent);
        });
      },
      onHorizontalDragEnd: (_) {
        final snap = _extent > actionWidth * 0.9
            ? _maxExtent
            : (_extent > actionWidth * 0.55 ? actionWidth : 0.0);
        setState(() => _extent = snap);
      },
      onTap: () {
        if (_extent != 0) setState(() => _extent = 0);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IgnorePointer(
              ignoring: !editVisible && !stockVisible,
              child: SizedBox(
                width: _maxExtent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Order: Stock then Edit (so Edit is rightmost).
                    Expanded(
                      child: Material(
                        color: AppColors.primaryPink.withOpacity(0.12),
                        child: InkWell(
                          onTap: stockVisible ? _handleEditStock : null,
                          child: const Center(child: Text('Stock')),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: AppColors.primaryPink.withOpacity(0.18),
                        child: InkWell(
                          onTap: editVisible ? _handleEditItem : null,
                          child: const Center(child: Text('Edit')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(-_extent, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
