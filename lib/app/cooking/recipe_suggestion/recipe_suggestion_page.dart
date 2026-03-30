import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/widgets/roomah_back_app_bar.dart';
import '../../../src/shared/glass_container.dart';

class RecipeSuggestionPage extends StatelessWidget {
  const RecipeSuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: roomahSolidBackAppBar(context, title: 'AI Suggestions'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.sparkles, color: AppColors.accentPink),
                      const SizedBox(width: 8),
                      Text("Top Pick For You", style: AppTextStyles.badgeText.copyWith(color: AppColors.accentPink)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Icon(LucideIcons.image, size: 50, color: Colors.grey)),
                  ),
                  const SizedBox(height: 16),
                  Text("Spicy Chicken Pasta", style: AppTextStyles.headerMedium),
                  const SizedBox(height: 8),
                  Text(
                    "You have 90% of the ingredients. You just need to buy fresh basil.",
                    style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 24),
                  Text("Ingredients", style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  const Text("• Chicken Breast (In Stock)"),
                  const Text("• Pasta (In Stock)"),
                  const Text("• Tomato Sauce (In Stock)"),
                  Text("• Fresh Basil (Missing)", style: TextStyle(color: AppColors.accentPink)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("START COOKING"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
