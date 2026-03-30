import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../src/core/theme/app_colors.dart';
import '../../src/core/theme/app_text_styles.dart';
import '../../src/widgets/roomah_back_app_bar.dart';
import '../../src/shared/custom_text_field.dart';
import '../../src/services/supabase_service.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notes = [];
  String? _householdId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Color _noteColor(String? hex) {
    if (hex == null || hex.runes.length < 7) return AppColors.primary;
    final v = hex.replaceFirst('#', '');
    if (v.runes.length != 6) return AppColors.primary;
    try {
      return Color(int.parse(v, radix: 16) + 0xFF000000);
    } catch (_) {
      return AppColors.primary;
    }
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final householdId = await SupabaseService().getCurrentHouseholdId();
      if (householdId != null) {
        _householdId = householdId;
        final list = await SupabaseService().getNotes(householdId);
        if (mounted) setState(() => _notes = list);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notes: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showNoteDialog({Map<String, dynamic>? existing}) async {
    if (_householdId == null) return;

    final titleCtrl = TextEditingController(text: existing?['title'] as String? ?? '');
    final contentCtrl = TextEditingController(text: existing?['content'] as String? ?? '');
    final colorCtrl = TextEditingController(text: existing?['color'] as String? ?? '#E23661');
    var pinned = existing?['is_pinned'] == true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceLight,
            title: Text(
              existing == null ? 'New note' : 'Edit note',
              style: AppTextStyles.headerMedium.copyWith(fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(label: 'Title (optional)', controller: titleCtrl),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Content',
                    controller: contentCtrl,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Color (#RRGGBB)',
                    controller: colorCtrl,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: pinned,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setDialogState(() => pinned = v ?? false),
                      ),
                      Text('Pinned', style: AppTextStyles.bodyRegular),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariantLight)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      ),
    );

    final content = contentCtrl.text.trim();
    final titleText = titleCtrl.text.trim();
    final colorText = colorCtrl.text.trim();
    titleCtrl.dispose();
    contentCtrl.dispose();
    colorCtrl.dispose();

    if (saved != true || !mounted) return;

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content is required.')),
      );
      return;
    }

    try {
      if (existing == null) {
        await SupabaseService().createNote(
          householdId: _householdId!,
          content: content,
          title: titleText.isEmpty ? null : titleText,
          color: colorText.isEmpty ? '#E23661' : colorText,
          isPinned: pinned,
        );
      } else {
        await SupabaseService().updateNote(
          noteId: existing['id'] as String,
          title: titleText,
          content: content,
          color: colorText.isEmpty ? '#E23661' : colorText,
          isPinned: pinned,
        );
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    }
  }

  Future<void> _togglePin(Map<String, dynamic> note) async {
    try {
      await SupabaseService().updateNote(
        noteId: note['id'] as String,
        isPinned: !(note['is_pinned'] == true),
      );
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
      await SupabaseService().deleteNote(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting note: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: roomahSolidBackAppBar(context, title: 'Fridge notes'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sticky notes for your household.',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 20),
                    if (_notes.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            'No notes yet',
                            style: AppTextStyles.bodyRegular.copyWith(color: AppColors.onSurfaceVariantLight),
                          ),
                        ),
                      )
                    else
                      ..._notes.map((note) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Dismissible(
                              key: Key(note['id'] as String),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(LucideIcons.trash2, color: Colors.white),
                              ),
                              onDismissed: (_) => _deleteNote(note['id'] as String),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _showNoteDialog(existing: note),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: _noteColor(note['color'] as String?),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  if ((note['title'] as String?)?.isNotEmpty ?? false)
                                                    Text(
                                                      note['title'] as String,
                                                      style: AppTextStyles.cardTitle.copyWith(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  if ((note['title'] as String?)?.isNotEmpty ?? false)
                                                    const SizedBox(height: 8),
                                                  Text(
                                                    note['content'] as String? ?? '',
                                                    style: AppTextStyles.bodyRegular.copyWith(
                                                      color: Colors.white.withOpacity(0.95),
                                                    ),
                                                    maxLines: 6,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                note['is_pinned'] == true
                                                    ? LucideIcons.pin
                                                    : LucideIcons.pinOff,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                              onPressed: () => _togglePin(note),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                  ],
                ),
              ),
    );
  }
}
