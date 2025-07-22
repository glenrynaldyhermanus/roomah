import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) {
      return 0;
    }
    if (location.startsWith('/todo')) {
      return 1;
    }
    if (location.startsWith('/finance')) {
      return 2;
    }
    if (location.startsWith('/routines')) {
      return 3;
    }
    if (location.startsWith('/calendar')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/dashboard');
        break;
      case 1:
        GoRouter.of(context).go('/todo');
        break;
      case 2:
        GoRouter.of(context).go('/finance');
        break;
      case 3:
        GoRouter.of(context).go('/routines');
        break;
      case 4:
        GoRouter.of(context).go('/calendar');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.house()),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.checkSquare()),
            label: 'To-Do',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.creditCard()),
            label: 'Finance',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.repeat()),
            label: 'Routines',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.calendar()),
            label: 'Calendar',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
