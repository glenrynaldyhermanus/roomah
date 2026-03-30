import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/widgets/roomah_back_app_bar.dart';
import '../../../src/shared/custom_text_field.dart';
import '../../../src/shared/glass_container.dart';
import '../../../src/services/supabase_service.dart';

class StoresPage extends StatefulWidget {
  const StoresPage({super.key});

  @override
  State<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _stores = [];
  String? _householdId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final householdId = await SupabaseService().getCurrentHouseholdId();
      if (householdId != null) {
        _householdId = householdId;
        final list = await SupabaseService().getStores(householdId);
        if (mounted) {
          setState(() => _stores = list);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stores: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openContact(Map<String, dynamic> store) async {
    final wa = store['whatsapp_number'] as String?;
    final url = store['contact_url'] as String?;
    final ok = await SupabaseService.openStoreContact(
      whatsappNumber: wa,
      contactUrl: url,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No WhatsApp number or contact URL set.')),
      );
    }
  }

  Future<void> _showStoreDialog({Map<String, dynamic>? existing}) async {
    if (_householdId == null) return;

    final nameCtrl = TextEditingController(text: existing?['name'] as String? ?? '');
    final waCtrl = TextEditingController(
      text: existing?['whatsapp_number'] as String? ?? '',
    );
    final urlCtrl = TextEditingController(
      text: existing?['contact_url'] as String? ?? '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text(
          existing == null ? 'Add store' : 'Edit store',
          style: AppTextStyles.headerMedium.copyWith(fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(label: 'Name', controller: nameCtrl),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'WhatsApp number',
                hint: 'e.g. 6281234567890',
                keyboardType: TextInputType.phone,
                controller: waCtrl,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Contact URL',
                hint: 'https://...',
                keyboardType: TextInputType.url,
                controller: urlCtrl,
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
      ),
    );

    if (saved != true || !mounted) {
      nameCtrl.dispose();
      waCtrl.dispose();
      urlCtrl.dispose();
      return;
    }

    final name = nameCtrl.text.trim();
    final waText = waCtrl.text;
    final urlText = urlCtrl.text;
    nameCtrl.dispose();
    waCtrl.dispose();
    urlCtrl.dispose();

    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name is required.')),
        );
      }
      return;
    }

    try {
      if (existing == null) {
        await SupabaseService().createStore(
          name: name,
          householdId: _householdId!,
          whatsappNumber: waText,
          contactUrl: urlText,
        );
      } else {
        await SupabaseService().updateStore(
          storeId: existing['id'] as String,
          name: name,
          whatsappNumber: waText,
          contactUrl: urlText,
        );
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving store: $e')),
        );
      }
    }
  }

  Future<void> _deleteStore(String id) async {
    try {
      await SupabaseService().deleteStore(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting store: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: roomahSolidBackAppBar(context, title: 'Stores & contacts'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStoreDialog(),
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
                    'Save shop contacts and open WhatsApp or a link.',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 20),
                    if (_stores.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            'No stores yet',
                            style: AppTextStyles.bodyRegular.copyWith(color: AppColors.onSurfaceVariantLight),
                          ),
                        ),
                      )
                    else
                      ..._stores.map((store) {
                        final wa = store['whatsapp_number'] as String?;
                        final url = store['contact_url'] as String?;
                        final hasContact = (wa != null && wa.replaceAll(RegExp(r'\D'), '').isNotEmpty) ||
                            (url != null && url.trim().isNotEmpty);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        store['name'] as String? ?? 'Store',
                                        style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(LucideIcons.pencil, color: AppColors.primary, size: 20),
                                      onPressed: () => _showStoreDialog(existing: store),
                                    ),
                                    IconButton(
                                      icon: Icon(LucideIcons.trash2,
                                          color: AppColors.onSurfaceVariantLight.withOpacity(0.9), size: 20),
                                      onPressed: () => _deleteStore(store['id'] as String),
                                    ),
                                  ],
                                ),
                                if (!hasContact)
                                  Text(
                                    'Add WhatsApp or URL to open a chat.',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariantLight),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      if (wa != null && wa.replaceAll(RegExp(r'\D'), '').isNotEmpty)
                                        Text(
                                          wa,
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      if (url != null && url.trim().isNotEmpty)
                                        Text(
                                          url,
                                          style: AppTextStyles.bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: hasContact ? () => _openContact(store) : null,
                                    icon: const Icon(LucideIcons.messageCircle, color: AppColors.primary, size: 18),
                                    label: Text(
                                      'WhatsApp / open link',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.primary),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
    );
  }
}
