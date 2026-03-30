// Basic Flutter widget test for Roomah.

import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:roomah/main.dart';

void main() {
  testWidgets('Splash shows home icon', (WidgetTester tester) async {
    await tester.pumpWidget(const RoomahApp());
    await tester.pump();

    expect(find.byIcon(LucideIcons.house), findsOneWidget);

    // SplashPage schedules a 2s timer; flush it so the test binding does not
    // report a pending timer after dispose.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
