import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/shared/custom_text_field.dart';
import '../../../src/shared/format_rupiah.dart';
import '../../../src/services/supabase_service.dart';

/// Edit an existing inventory item (details + photo + optional dates).
Future<bool?> showEditInventoryItemBottomSheet(
  BuildContext context, {
  required String itemId,
  required String householdId,
  required String categoryId,
  required int initialQuantity,
  required int initialLowStockThreshold,
  required String initialName,
  required String initialBrand,
  required dynamic initialPrice,
  required String initialPurchaseLink,
  required String? initialImageUrl,
  required DateTime? initialPurchaseDate,
  required DateTime? initialExpireDate,
  required String categoryName,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _EditItemSheetBody(
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
    ),
  );
}

class _EditItemSheetBody extends StatefulWidget {
  const _EditItemSheetBody({
    required this.itemId,
    required this.householdId,
    required this.categoryId,
    required this.categoryName,
    required this.initialQuantity,
    required this.initialLowStockThreshold,
    required this.initialName,
    required this.initialBrand,
    required this.initialPrice,
    required this.initialPurchaseLink,
    required this.initialImageUrl,
    required this.initialPurchaseDate,
    required this.initialExpireDate,
  });

  final String itemId;
  final String householdId;
  final String categoryId;
  final String categoryName;

  final int initialQuantity;
  final int initialLowStockThreshold;

  final String initialName;
  final String initialBrand;
  final dynamic initialPrice;
  final String initialPurchaseLink;
  final String? initialImageUrl;
  final DateTime? initialPurchaseDate;
  final DateTime? initialExpireDate;

  @override
  State<_EditItemSheetBody> createState() => _EditItemSheetBodyState();
}

class _EditItemSheetBodyState extends State<_EditItemSheetBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _priceController;
  late final TextEditingController _linkController;
  late final TextEditingController _lowStockThresholdController;

  final _picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _imageMime;
  bool _isLoading = false;

  DateTime? _purchaseDate;
  DateTime? _expireDate;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _brandController = TextEditingController(text: widget.initialBrand);
    _linkController = TextEditingController(text: widget.initialPurchaseLink);
    _lowStockThresholdController = TextEditingController(
      text: widget.initialLowStockThreshold.toString(),
    );

    // Numeric(N) coming from Postgres usually arrives as num/string depending on driver.
    final priceNum = coerceNum(widget.initialPrice);
    _priceController = TextEditingController(
      text: priceNum == null ? '' : priceNum.round().toString(),
    );

    _purchaseDate = widget.initialPurchaseDate;
    _expireDate = widget.initialExpireDate;
    _existingImageUrl = widget.initialImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _linkController.dispose();
    _lowStockThresholdController.dispose();
    super.dispose();
  }

  int? _parseLowStockThreshold(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    final v = int.tryParse(t);
    if (v == null) return null;
    return v;
  }

  String _statusForQuantity(int q, int lowStockThreshold) {
    if (q <= 0) return 'out_of_stock';
    if (q <= lowStockThreshold) return 'low_stock';
    return 'in_stock';
  }

  String _extFromMime(String? mime) {
    switch (mime?.toLowerCase()) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/gif':
        return 'gif';
      case 'image/heic':
      case 'image/heif':
        return 'heic';
      default:
        return 'jpg';
    }
  }

  String _contentTypeForExt(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'heic':
      case 'heif':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }

  String _formatDateYYYYMMDD(DateTime? d) {
    if (d == null) return '';
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> _pickPurchaseDate() async {
    final now = DateTime.now();
    final initial = _purchaseDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 50),
    );
    if (picked == null) return;
    setState(() => _purchaseDate = picked);
  }

  Future<void> _pickExpireDate() async {
    final now = DateTime.now();
    final initial = _expireDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 50),
    );
    if (picked == null) return;
    setState(() => _expireDate = picked);
  }

  Future<void> _pickFrom(ImageSource source) async {
    try {
      final x = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        imageQuality: 88,
      );
      if (x == null || !mounted) return;
      final bytes = await x.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageMime = x.mimeType;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn’t open photos: $e')),
      );
    }
  }

  void _schedulePickAfterSourceSheetDismissed(ImageSource source) {
    void afterFrames(int remaining) {
      if (remaining > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) => afterFrames(remaining - 1));
        return;
      }
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _pickFrom(source);
      });
    }

    afterFrames(2);
  }

  Future<void> _openImageSourceSheet() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Update photo',
                style: AppTextStyles.headerMedium.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              Material(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    _schedulePickAfterSourceSheetDismissed(ImageSource.gallery);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(LucideIcons.images, color: AppColors.accentPink, size: 24),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Gallery', style: AppTextStyles.bodyRegular)),
                        Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Material(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    _schedulePickAfterSourceSheetDismissed(ImageSource.camera);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(LucideIcons.camera, color: AppColors.accentPink, size: 24),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Camera', style: AppTextStyles.bodyRegular)),
                        Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _imageMime = null;
      _existingImageUrl = null;
    });
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        throw Exception('Name is required');
      }

      final price = parseIdrPriceInput(_priceController.text);
      final brand = _brandController.text.trim();
      final link = _linkController.text.trim();
      final threshold =
          _parseLowStockThreshold(_lowStockThresholdController.text);
      if (threshold == null) throw Exception('Low stock threshold is invalid');
      if (threshold < 0) throw Exception('Low stock threshold cannot be negative');

      String? imageUrlToUpdate;
      final bytes = _imageBytes;
      if (bytes != null && bytes.isNotEmpty) {
        final ext = _extFromMime(_imageMime);
        final contentType = _imageMime ?? _contentTypeForExt(ext);
        imageUrlToUpdate = await SupabaseService().uploadInventoryItemImage(
          householdId: widget.householdId,
          bytes: bytes,
          contentType: contentType,
          fileExtension: ext,
        );
      }

      final purchaseDate = _formatDateYYYYMMDD(_purchaseDate);
      final expireDate = _formatDateYYYYMMDD(_expireDate);

      final update = <String, dynamic>{
        'name': name,
        'brand': brand,
        'price': price,
        'purchase_link': link,
        'category_id': widget.categoryId,
        'purchase_date': purchaseDate.isEmpty ? null : purchaseDate,
        'expire_date': expireDate.isEmpty ? null : expireDate,
        'low_stock_threshold': threshold,
        'status': _statusForQuantity(widget.initialQuantity, threshold),
      };

      if (imageUrlToUpdate != null) {
        update['image_url'] = imageUrlToUpdate;
      } else if (_existingImageUrl == null) {
        // If user explicitly cleared photo, remove it.
        update['image_url'] = null;
      }

      await SupabaseService().updateInventoryItem(
        itemId: widget.itemId,
        householdId: widget.householdId,
        updateData: update,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
                'Edit ${widget.categoryName}',
                style: AppTextStyles.headerMedium.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                'Photo',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              Material(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _isLoading ? null : _openImageSourceSheet,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _imageBytes != null
                              ? Image.memory(
                                  _imageBytes!,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                )
                              : (_existingImageUrl != null
                                  ? Image.network(
                                      _existingImageUrl!.trim(),
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) {
                                        return Container(
                                          width: 64,
                                          height: 64,
                                          color: Colors.white.withOpacity(0.5),
                                          child: Icon(
                                            LucideIcons.imageOff,
                                            color: AppColors.textMuted,
                                            size: 28,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 64,
                                      height: 64,
                                      color: Colors.white.withOpacity(0.5),
                                      child: Icon(
                                        LucideIcons.imagePlus,
                                        color: AppColors.textMuted,
                                        size: 28,
                                      ),
                                    )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _imageBytes != null || _existingImageUrl != null
                                ? 'Change / remove photo'
                                : 'Add a photo',
                            style: AppTextStyles.bodyRegular,
                          ),
                        ),
                        if (_imageBytes != null || _existingImageUrl != null)
                          IconButton(
                            onPressed: _isLoading ? null : _clearImage,
                            icon: Icon(LucideIcons.x, color: AppColors.textMuted, size: 22),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Item name',
                hint: 'e.g. Dish soap',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Brand',
                hint: 'e.g. IKEA',
                controller: _brandController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Price',
                hint: 'e.g. 25000',
                keyboardType: TextInputType.number,
                controller: _priceController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Low stock threshold',
                hint: 'e.g. 3',
                keyboardType: TextInputType.number,
                controller: _lowStockThresholdController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Purchase link',
                hint: 'https://…',
                controller: _linkController,
              ),
              const SizedBox(height: 24),
              Material(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _isLoading ? null : _pickPurchaseDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(LucideIcons.calendarDays, color: AppColors.accentPink, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _purchaseDate == null
                                ? 'Purchase date'
                                : 'Purchase: ${_formatDateYYYYMMDD(_purchaseDate)}',
                            style: AppTextStyles.bodyRegular,
                          ),
                        ),
                        Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _isLoading ? null : _pickExpireDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(LucideIcons.calendar, color: AppColors.accentPink, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _expireDate == null
                                ? 'Expire date'
                                : 'Expire: ${_formatDateYYYYMMDD(_expireDate)}',
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
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    : Text(
                        'Save changes',
                        style: AppTextStyles.cardTitle.copyWith(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

