import 'package:flutter/material.dart';

import '../../src/core/theme/app_colors.dart';
import '../../src/widgets/roomah_back_app_bar.dart';
import '../../src/services/supabase_service.dart';
import '../../src/shared/custom_text_field.dart';

class RecipeEditPage extends StatefulWidget {
  const RecipeEditPage({
    super.key,
    required this.householdId,
    this.existing,
  });

  final String householdId;
  final Map<String, dynamic>? existing;

  bool get isEditing => existing != null;

  @override
  State<RecipeEditPage> createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends State<RecipeEditPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _instrCtrl;
  late final TextEditingController _prepCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?['title'] as String? ?? '');
    _descCtrl = TextEditingController(text: e?['description'] as String? ?? '');
    _instrCtrl = TextEditingController(text: e?['instructions'] as String? ?? '');
    final prep = e?['prep_time_minutes'];
    _prepCtrl = TextEditingController(
      text: prep is int ? '$prep' : (prep is num ? '${prep.toInt()}' : ''),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _instrCtrl.dispose();
    _prepCtrl.dispose();
    super.dispose();
  }

  int? _parsePrep() {
    final s = _prepCtrl.text.trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      if (widget.isEditing) {
        final id = widget.existing!['id'] as String;
        await SupabaseService().updateRecipe(
          recipeId: id,
          householdId: widget.householdId,
          title: title,
          description: _descCtrl.text,
          instructions: _instrCtrl.text,
          prepTimeMinutes: _parsePrep(),
        );
      } else {
        await SupabaseService().createRecipe(
          householdId: widget.householdId,
          title: title,
          description: _descCtrl.text,
          instructions: _instrCtrl.text,
          prepTimeMinutes: _parsePrep(),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: roomahSolidBackAppBar(
        context,
        title: widget.isEditing ? 'Edit recipe' : 'New recipe',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: 'Title',
              hint: 'Recipe name',
              controller: _titleCtrl,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Description',
              hint: 'Short summary (optional)',
              controller: _descCtrl,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Instructions',
              hint: 'Steps (optional)',
              controller: _instrCtrl,
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Prep time (minutes)',
              hint: 'e.g. 30',
              controller: _prepCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(widget.isEditing ? 'Save changes' : 'Add recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
