import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';

/// Title + gap under bottom-nav tab roots (no Material AppBar).
/// Parent should wrap scroll content with `padding: EdgeInsets.all(20)` like [EventListPage].
class RoomahNavTabTitleBlock extends StatelessWidget {
  const RoomahNavTabTitleBlock({super.key, required this.title});

  final String title;

  /// Same horizontal + top inset as [EventListPage] body.
  static const EdgeInsets scrollPadding = EdgeInsets.all(20);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTextStyles.headerMedium),
        const SizedBox(height: 20),
      ],
    );
  }
}
