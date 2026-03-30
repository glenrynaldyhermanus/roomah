import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../src/core/theme/app_colors.dart';
import '../../src/core/theme/app_text_styles.dart';
import '../../src/widgets/roomah_back_app_bar.dart';
import '../../src/shared/custom_text_field.dart';
import '../../src/shared/glass_container.dart';
import '../../src/services/supabase_service.dart';

class _MatLine {
  _MatLine({
    required this.itemId,
    required this.displayName,
    required this.notesController,
    required this.optional,
  });

  final String itemId;
  final String displayName;
  final TextEditingController notesController;
  bool optional;
}

List<String> _parseSteps(dynamic steps) {
  if (steps == null) return [''];
  if (steps is List && steps.isNotEmpty) {
    final out = steps.map((e) => e?.toString() ?? '').toList();
    return out.isEmpty ? [''] : out;
  }
  return [''];
}

class GuideEditorPage extends StatefulWidget {
  const GuideEditorPage({super.key, required this.householdId, this.guideId});

  final String householdId;
  final String? guideId;

  @override
  State<GuideEditorPage> createState() => _GuideEditorPageState();
}

class _GuideEditorPageState extends State<GuideEditorPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final List<TextEditingController> _stepControllers = [];
  final List<_MatLine> _materials = [];
  bool _loading = true;
  bool _saving = false;
  List<Map<String, dynamic>> _catalogCache = [];

  bool get _isEdit => widget.guideId != null;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (_isEdit) {
      await _loadExisting();
    } else {
      _stepControllers.add(TextEditingController());
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadExisting() async {
    try {
      _catalogCache = await SupabaseService().getCatalogItems(widget.householdId);
      final g = await SupabaseService().getGuideById(widget.guideId!, widget.householdId);
      if (!mounted) return;
      if (g == null) {
        setState(() => _loading = false);
        return;
      }
      _titleController.text = g['title'] as String? ?? '';
      _descController.text = g['description'] as String? ?? '';
      final steps = _parseSteps(g['steps']);
      for (final s in steps) {
        _stepControllers.add(TextEditingController(text: s));
      }
      final raw = g['guide_items'];
      if (raw is List) {
        for (final row in raw) {
          if (row is! Map<String, dynamic>) continue;
          final nested = row['items'];
          final name =
              nested is Map<String, dynamic>
                  ? (nested['name'] as String? ?? 'Item')
                  : 'Item';
          final iid = row['item_id'] as String?;
          if (iid == null) continue;
          _materials.add(
            _MatLine(
              itemId: iid,
              displayName: name,
              notesController: TextEditingController(text: row['notes'] as String? ?? ''),
              optional: row['is_optional'] as bool? ?? false,
            ),
          );
        }
      }
      setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (final c in _stepControllers) {
      c.dispose();
    }
    for (final m in _materials) {
      m.notesController.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() => _stepControllers.add(TextEditingController()));
  }

  void _removeStep(int i) {
    if (_stepControllers.length <= 1) return;
    setState(() {
      _stepControllers.removeAt(i).dispose();
    });
  }

  void _removeMaterial(int i) {
    setState(() {
      _materials.removeAt(i).notesController.dispose();
    });
  }

  Future<void> _pickOrCreateMaterial() async {
    if (_catalogCache.isEmpty) {
      _catalogCache = await SupabaseService().getCatalogItems(widget.householdId);
    }
    if (!mounted) return;
    final searchController = TextEditingController();
    final newNameController = TextEditingController();
    List<Map<String, dynamic>> filtered = List.from(_catalogCache);

    void applyFilter() {
      final q = searchController.text.trim().toLowerCase();
      filtered =
          q.isEmpty
              ? List.from(_catalogCache)
              : _catalogCache
                  .where((e) => (e['name'] as String? ?? '').toLowerCase().contains(q))
                  .toList();
    }

    final picked = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Add material', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search catalog…',
                      hintStyle: AppTextStyles.bodySmall,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (_) => setModal(() => applyFilter()),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child:
                        filtered.isEmpty
                            ? Center(
                              child: Text('No matches', style: AppTextStyles.bodySmall),
                            )
                            : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final it = filtered[i];
                                final name = it['name'] as String? ?? '';
                                return ListTile(
                                  title: Text(name, style: AppTextStyles.bodyRegular),
                                  onTap: () => Navigator.pop(ctx, it),
                                );
                              },
                            ),
                  ),
                  const Divider(),
                  Text('New catalog item', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 8),
                  TextField(
                    controller: newNameController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Baking soda',
                      hintStyle: AppTextStyles.bodySmall,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final name = newNameController.text.trim();
                      if (name.isEmpty) return;
                      try {
                        final row = await SupabaseService().createCatalogItem(
                          name: name,
                          householdId: widget.householdId,
                        );
                        _catalogCache = await SupabaseService().getCatalogItems(widget.householdId);
                        if (ctx.mounted) Navigator.pop(ctx, row);
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(
                            ctx,
                          ).showSnackBar(SnackBar(content: Text('$e')));
                        }
                      }
                    },
                    icon: const Icon(LucideIcons.plus),
                    label: const Text('Create & use'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    searchController.dispose();
    newNameController.dispose();

    if (picked != null && mounted) {
      final id = picked['id'] as String?;
      final name = picked['name'] as String? ?? '';
      if (id == null) return;
      if (_materials.any((m) => m.itemId == id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already in list')),
        );
        return;
      }
      setState(() {
        _materials.add(
          _MatLine(
            itemId: id,
            displayName: name,
            notesController: TextEditingController(),
            optional: false,
          ),
        );
      });
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    final steps =
        _stepControllers
            .map((c) => c.text.trim())
            .where((s) => s.isNotEmpty)
            .toList();

    setState(() => _saving = true);
    try {
      final svc = SupabaseService();
      String guideId;
      if (_isEdit) {
        guideId = widget.guideId!;
        await svc.updateGuide(
          guideId: guideId,
          householdId: widget.householdId,
          title: title,
          description: _descController.text,
          stepsJson: steps.isEmpty ? <dynamic>[] : steps,
        );
      } else {
        final row = await svc.createGuide(
          householdId: widget.householdId,
          title: title,
          description: _descController.text.isEmpty ? null : _descController.text,
          stepsJson: steps.isEmpty ? <dynamic>[] : steps,
        );
        guideId = row['id'] as String;
      }

      final itemRows = <Map<String, dynamic>>[];
      for (final m in _materials) {
        itemRows.add({
          'guide_id': guideId,
          'item_id': m.itemId,
          'notes': m.notesController.text.trim().isEmpty ? null : m.notesController.text.trim(),
          'is_optional': m.optional,
        });
      }
      await svc.replaceGuideItems(guideId: guideId, rows: itemRows);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: roomahSolidBackAppBar(context, title: ''),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: roomahSolidBackAppBar(
        context,
        title: _isEdit ? 'Edit guide' : 'New guide',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(label: 'Title', controller: _titleController, hint: 'e.g. Mop the floor'),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Description (optional)',
              controller: _descController,
              hint: 'Short context',
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Steps', style: AppTextStyles.cardTitle),
                TextButton.icon(
                  onPressed: _addStep,
                  icon: const Icon(LucideIcons.plus, size: 18, color: AppColors.primary),
                  label: Text('Add step', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < _stepControllers.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      label: '',
                      controller: _stepControllers[i],
                      hint: 'Instruction (ratios, tips…)',
                      maxLines: 4,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeStep(i),
                    icon: Icon(LucideIcons.x, color: AppColors.textMuted.withOpacity(0.8)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Materials', style: AppTextStyles.cardTitle),
                TextButton.icon(
                  onPressed: _pickOrCreateMaterial,
                  icon: const Icon(LucideIcons.package, size: 18, color: AppColors.primary),
                  label: Text('Add from catalog', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_materials.isEmpty)
              Text(
                'Link items from your catalog to check them against inventory.',
                style: AppTextStyles.bodySmall,
              )
            else
              GlassContainer(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    for (var i = 0; i < _materials.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _materials[i].displayName,
                                  style: AppTextStyles.bodyRegular.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                CustomTextField(
                                  label: 'Notes (amount / use)',
                                  controller: _materials[i].notesController,
                                  hint: 'e.g. 2 caps, 1 bucket water',
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _materials[i].optional,
                                      onChanged: (v) {
                                        setState(() => _materials[i].optional = v ?? false);
                                      },
                                    ),
                                    Text('Optional', style: AppTextStyles.bodySmall),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeMaterial(i),
                            icon: Icon(LucideIcons.trash2, color: AppColors.accentPink.withOpacity(0.85)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child:
                _saving
                    ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                    : Text('Save', style: AppTextStyles.bodyRegular.copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
