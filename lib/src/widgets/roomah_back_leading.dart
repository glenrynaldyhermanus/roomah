import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme/app_colors.dart';

/// Shared back control for AppBars and similar chrome.
Widget roomahChevronBackButton(
  BuildContext context, {
  VoidCallback? onPressed,
}) {
  return IconButton(
    icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textDark),
    onPressed: onPressed ?? () => Navigator.pop(context),
  );
}
