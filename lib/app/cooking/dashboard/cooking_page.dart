import 'package:flutter/material.dart';
import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/shared/glass_container.dart';
import '../recipe_suggestion/recipe_suggestion_page.dart';

class CookingPage extends StatelessWidget {
  const CookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Kitchen Assistant", style: AppTextStyles.headerMedium),
          const SizedBox(height: 20),
          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.restaurant_menu, size: 64, color: AppColors.primaryPink),
                const SizedBox(height: 16),
                Text(
                  "What should we cook today?",
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Based on your inventory: Chicken, Tomatoes, Pasta...",
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecipeSuggestionPage()),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("SUGGEST RECIPES (AI)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text("Recent Favorites", style: AppTextStyles.cardTitle),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.fastfood, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Creamy Pasta ${index + 1}", style: AppTextStyles.cardTitle),
                            Text("30 mins • Easy", style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
