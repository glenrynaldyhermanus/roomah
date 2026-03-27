import 'package:flutter/material.dart';
import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/shared/glass_container.dart';
import '../../../src/shared/custom_text_field.dart';
import '../../../src/services/supabase_service.dart';

class AddItemPage extends StatefulWidget {
  final String categoryName;
  final String categoryId;
  final String householdId;

  const AddItemPage({
    super.key, 
    required this.categoryName,
    required this.categoryId,
    required this.householdId,
  });

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _linkController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        throw Exception('Name is required');
      }

      final price = double.tryParse(_priceController.text.trim());

      await SupabaseService().addInventoryItem({
        'name': name,
        'brand': _brandController.text.trim(),
        'price': price,
        'purchase_link': _linkController.text.trim(),
        'category_id': widget.categoryId,
        'household_id': widget.householdId,
        'status': 'in_stock',
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item added successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Add to ${widget.categoryName}", style: AppTextStyles.cardTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(label: "Item Name", hint: "e.g. Dish Soap", controller: _nameController),
              const SizedBox(height: 16),
              CustomTextField(label: "Brand", hint: "e.g. IKEA", controller: _brandController),
              const SizedBox(height: 16),
              CustomTextField(label: "Price", hint: "e.g. 12.99", keyboardType: TextInputType.number, controller: _priceController),
              const SizedBox(height: 16),
              CustomTextField(label: "Purchase Link", hint: "https://...", controller: _linkController),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                    : const Text("SAVE ITEM"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
