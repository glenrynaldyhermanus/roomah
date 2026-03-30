import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../src/core/theme/app_colors.dart';
import 'home_dashboard.dart';
import '../events/event_list/event_list_page.dart';
import '../cooking/dashboard/cooking_page.dart';
import '../randomizer/dice/dice_page.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  List<Widget> _createPages() => [
        HomeDashboard(onOpenCalendar: () => setState(() => _currentIndex = 1)),
        const EventListPage(),
        const CookingPage(),
        const DicePage(),
      ];

  @override
  void initState() {
    super.initState();
    _pages = _createPages();
  }

  /// Hot reload keeps [State] but does not re-run [initState]; rebuild tabs so
  /// length matches [BottomNavigationBar] and clamp index (e.g. 3 vs 3 items).
  @override
  void reassemble() {
    super.reassemble();
    _pages = _createPages();
    _currentIndex = _currentIndex.clamp(0, _pages.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final i = _currentIndex.clamp(0, _pages.length - 1);
    if (i != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = i);
      });
    }
    return Scaffold(
      body: _pages[i],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          border: Border(
            top: BorderSide(
              color: AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: i,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariantLight,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.house),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.calendarDays),
              label: 'Plans',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.chefHat),
              label: 'Cooking',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.dices),
              label: 'Dice',
            ),
          ],
        ),
      ),
    );
  }
}
