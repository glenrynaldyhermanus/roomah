import 'package:go_router/go_router.dart';
import 'package:myapp/app/screens/calendar/calendar_screen.dart';
import 'package:myapp/app/screens/dashboard/dashboard_screen.dart';
import 'package:myapp/app/screens/finance/finance_screen.dart';
import 'package:myapp/app/screens/main_screen.dart';
import 'package:myapp/app/screens/todo/todo_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/todo',
            builder: (context, state) => const TodoScreen(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/finance',
            builder: (context, state) => const FinanceScreen(),
          ),
        ],
      ),
    ],
  );
}
