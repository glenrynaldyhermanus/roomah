import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:myapp/app/screens/dashboard/dashboard_screen.dart';
import 'package:myapp/app/screens/todo/todo_screen.dart';
import 'package:myapp/app/screens/budget/budget_screen.dart';
import 'package:myapp/app/screens/calendar/calendar_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    TodoScreen(),
    BudgetScreen(),
    CalendarScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
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
            icon: Icon(PhosphorIcons.wallet()),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.calendar()),
            label: 'Calendar',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Penting untuk lebih dari 3 item
      ),
    );
  }
}
