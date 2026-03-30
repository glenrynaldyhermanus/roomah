import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/shared/custom_text_field.dart';
import '../../../src/services/supabase_service.dart';
import '../../../src/shared/format_rupiah.dart';

/// Returns `true` if an item was saved; `null` if dismissed without saving.
Future<bool?> showAddInventoryItemBottomSheet(
  BuildContext context, {
  required String categoryName,
  required String categoryId,
  required String householdId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _AddItemSheetBody(
      categoryName: categoryName,
      categoryId: categoryId,
      householdId: householdId,
    ),
  );
}

class _AddItemSheetBody extends StatefulWidget {
  const _AddItemSheetBody({
    required this.categoryName,
    required this.categoryId,
    required this.householdId,
  });

  final String categoryName;
  final String categoryId;
  final String householdId;

  @override
  State<_AddItemSheetBody> createState() => _AddItemSheetBodyState();
}

class _AddItemSheetBodyState extends State<_AddItemSheetBody> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _linkController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _lowStockThresholdController = TextEditingController(text: '3');
  final _picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _imageMime;
  bool _isLoading = false;
  DateTime? _purchaseDate;
  DateTime? _expireDate;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _linkController.dispose();
    _quantityController.dispose();
    _lowStockThresholdController.dispose();
    super.dispose();
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
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'channel-error') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Photo picker isn’t ready — fully stop the app and run again (don’t rely on hot reload).',
            ),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn’t open photos: ${e.message ?? e.code}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn’t open photos: $e')),
      );
    }
  }

  /// Picks after the source sheet route is gone — avoids an Android Pigeon/channel race.
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
              Text('Add photo', style: AppTextStyles.headerMedium.copyWith(fontSize: 18)),
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
      final quantity = int.tryParse(_quantityController.text.trim());
      if (quantity == null) throw Exception('Current stock is invalid');

      final lowStockThreshold =
          int.tryParse(_lowStockThresholdController.text.trim());
      if (lowStockThreshold == null) {
        throw Exception('Low stock threshold is invalid');
      }
      if (lowStockThreshold < 0) {
        throw Exception('Low stock threshold cannot be negative');
      }

      String? imageUrl;
      final bytes = _imageBytes;
      if (bytes != null && bytes.isNotEmpty) {
        final ext = _extFromMime(_imageMime);
        final contentType = _imageMime ?? _contentTypeForExt(ext);
        imageUrl = await SupabaseService().uploadInventoryItemImage(
          householdId: widget.householdId,
          bytes: bytes,
          contentType: contentType,
          fileExtension: ext,
        );
      }

      final insert = <String, dynamic>{
        'name': name,
        'brand': _brandController.text.trim(),
        'price': price,
        'purchase_link': _linkController.text.trim(),
        'category_id': widget.categoryId,
        'household_id': widget.householdId,
        'quantity': quantity,
        'low_stock_threshold': lowStockThreshold,
        'status': quantity <= 0
            ? 'out_of_stock'
            : quantity <= lowStockThreshold
                ? 'low_stock'
                : 'in_stock',
      };
      final purchaseDate = _formatDateYYYYMMDD(_purchaseDate);
      if (purchaseDate.isNotEmpty) {
        insert['purchase_date'] = purchaseDate;
      }
      final expireDate = _formatDateYYYYMMDD(_expireDate);
      if (expireDate.isNotEmpty) {
        insert['expire_date'] = expireDate;
      }
      if (imageUrl != null && imageUrl.isNotEmpty) {
        insert['image_url'] = imageUrl;
      }

      await SupabaseService().addInventoryItem(insert);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                'Add to ${widget.categoryName}',
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
                              : Container(
                                  width: 64,
                                  height: 64,
                                  color: Colors.white.withOpacity(0.5),
                                  child: Icon(LucideIcons.imagePlus, color: AppColors.textMuted, size: 28),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _imageBytes != null ? 'Change photo' : 'Add a photo (optional)',
                            style: AppTextStyles.bodyRegular,
                          ),
                        ),
                        if (_imageBytes != null)
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
                hint: 'e.g. 25000 or 25.000',
                keyboardType: TextInputType.number,
                controller: _priceController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Current stock',
                hint: 'e.g. 1',
                keyboardType: TextInputType.number,
                controller: _quantityController,
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
              // Date fields (optional) for inventory tracking.
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
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Save item',
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
