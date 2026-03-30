import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'roomah_back_leading.dart';

TextStyle get _roomahAppBarTitleStyle =>
    AppTextStyles.headerMedium.copyWith(fontSize: 20);

/// Solid app bar matching [InventoryDashboard] push chrome.
PreferredSizeWidget roomahSolidBackAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
  bool automaticallyImplyLeading = false,
}) {
  final canPop = Navigator.canPop(context);
  return AppBar(
    title: Text(title, style: _roomahAppBarTitleStyle),
    centerTitle: false,
    backgroundColor: AppColors.backgroundLight,
    foregroundColor: AppColors.textDark,
    elevation: 0,
    scrolledUnderElevation: 0,
    automaticallyImplyLeading: automaticallyImplyLeading,
    leading: canPop ? roomahChevronBackButton(context) : null,
    actions: actions,
  );
}

/// Transparent bar for onboarding-style screens (e.g. invite); same title/leading tokens.
PreferredSizeWidget roomahTransparentBackAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
  bool automaticallyImplyLeading = false,
}) {
  final canPop = Navigator.canPop(context);
  return AppBar(
    title: Text(title, style: _roomahAppBarTitleStyle),
    centerTitle: false,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textDark,
    elevation: 0,
    scrolledUnderElevation: 0,
    automaticallyImplyLeading: automaticallyImplyLeading,
    leading: canPop ? roomahChevronBackButton(context) : null,
    actions: actions,
  );
}
