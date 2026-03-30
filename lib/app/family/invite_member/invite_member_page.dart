import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/widgets/roomah_back_app_bar.dart';
import '../../../src/shared/glass_container.dart';
import '../../../src/shared/custom_text_field.dart';
import '../../../src/services/supabase_service.dart';
import '../../dashboard/main_dashboard.dart';

class InviteMemberPage extends StatefulWidget {
  final String householdId;
  const InviteMemberPage({super.key, required this.householdId});

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  final List<TextEditingController> _emailControllers = [TextEditingController()];
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _emailControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addEmailField() {
    setState(() {
      _emailControllers.add(TextEditingController());
    });
  }

  Future<void> _handleInvites() async {
    setState(() => _isLoading = true);
    try {
      final emails = _emailControllers
          .map((c) => c.text.trim())
          .where((email) => email.isNotEmpty)
          .toList();

      if (emails.isEmpty) {
        // Just proceed if no emails entered
        _navigateToDashboard();
        return;
      }

      for (var email in emails) {
        try {
          await SupabaseService().inviteMember(email, widget.householdId);
        } catch (e) {
          // Ignore individual failures for now, or collect them
          debugPrint("Failed to invite $email: $e");
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invites sent!")),
        );
        _navigateToDashboard();
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

  void _navigateToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainDashboard()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: roomahTransparentBackAppBar(
        context,
        title: 'Invite Members',
        actions: [
          TextButton(
            onPressed: _navigateToDashboard,
            child: Text(
              "Skip",
              style: AppTextStyles.bodyRegular.copyWith(color: AppColors.accentPink),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
           Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentPink.withOpacity(0.2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.accentPink,
                    blurRadius: 80,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Who lives with you?",
                        style: AppTextStyles.headerMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Invite them to join your household.",
                        style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ..._emailControllers.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CustomTextField(
                            label: "Member ${entry.key + 1} Email",
                            hint: "email@example.com",
                            keyboardType: TextInputType.emailAddress,
                            controller: entry.value,
                          ),
                        );
                      }),
                      TextButton.icon(
                        onPressed: _addEmailField,
                        icon: const Icon(LucideIcons.plus, color: AppColors.accentPink),
                        label: Text(
                          "Add Another Member",
                          style: AppTextStyles.bodyRegular.copyWith(color: AppColors.accentPink),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleInvites,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20, 
                                width: 20, 
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                              )
                            : const Text("SEND INVITES & FINISH"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
