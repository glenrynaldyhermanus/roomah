import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/models/todo_item.dart';
import 'package:myapp/app/models/routine.dart';
import 'package:myapp/app/models/calendar_event.dart';
import 'package:myapp/app/screens/calendar/calendar_screen.dart';
import 'package:myapp/app/screens/calendar/calendar_event_form_screen.dart';
import 'package:myapp/app/screens/dashboard/dashboard_screen.dart';
import 'package:myapp/app/screens/finance/finance_screen.dart';
import 'package:myapp/app/screens/finance/finance_form_screen.dart';
import 'package:myapp/app/screens/main_screen.dart';
import 'package:myapp/app/screens/todo/todo_form_screen.dart';
import 'package:myapp/app/screens/todo/todo_screen.dart';
import 'package:myapp/app/screens/routines/routines_screen.dart';
import 'package:myapp/app/screens/routines/routines_form_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) {
            return const DashboardScreen();
          },
        ),
        GoRoute(
          path: '/todo',
          builder: (context, state) {
            return const TodoScreen();
          },
          routes: [
            GoRoute(
              path: 'form',
              builder: (context, state) {
                final todo = state.extra as Todo?;
                return TodoFormScreen(todo: todo);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/finance',
          builder: (context, state) {
            return const FinanceScreen();
          },
          routes: [
            GoRoute(
              path: 'form',
              builder: (context, state) {
                return const FinanceFormScreen();
              },
            ),
          ],
        ),
        GoRoute(
          path: '/routines',
          builder: (context, state) {
            return const RoutinesScreen();
          },
          routes: [
            GoRoute(
              path: 'form',
              builder: (context, state) {
                final routine = state.extra as Routine?;
                return RoutinesFormScreen(routine: routine);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) {
            return const CalendarScreen();
          },
          routes: [
            GoRoute(
              path: 'event-form',
              builder: (context, state) {
                final event = state.extra as CalendarEvent?;
                return CalendarEventFormScreen(event: event);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
