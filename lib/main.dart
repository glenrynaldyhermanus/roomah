import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:myapp/app/blocs/calendar_data/calendar_data_bloc.dart';
import 'package:myapp/app/blocs/finance/finance_bloc.dart';
import 'package:myapp/app/blocs/todo/todo_bloc.dart';
import 'package:myapp/app/blocs/routines/routines_bloc.dart';
import 'package:myapp/app/blocs/routines/routines_event.dart';
import 'package:myapp/app/blocs/routine_categories/routine_categories_bloc.dart';
import 'package:myapp/app/blocs/routine_categories/routine_categories_event.dart';
import 'package:myapp/app/routes/app_router.dart';
import 'package:myapp/app/services/supabase_service.dart';
import 'package:myapp/app/themes/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fcqehsciylskujjtqvxw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZjcWVoc2NpeWxza3VqanRxdnh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI4MzUyNjAsImV4cCI6MjA2ODQxMTI2MH0.5vCzfyqIwTeQyBYVkHTTJVK0ObymT4YqvNu9L_XX7vY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(create: (context) => SupabaseService()),
        BlocProvider(
          create:
              (context) =>
                  TodoBloc(RepositoryProvider.of<SupabaseService>(context))
                    ..add(FetchTodos()),
        ),
        BlocProvider(
          create:
              (context) => CalendarDataBloc(
                RepositoryProvider.of<SupabaseService>(context),
              ),
        ),
        BlocProvider(
          create:
              (context) =>
                  FinanceBloc(RepositoryProvider.of<SupabaseService>(context))
                    ..add(FetchFinances()),
        ),
        BlocProvider(
          create:
              (context) =>
                  RoutinesBloc(RepositoryProvider.of<SupabaseService>(context))
                    ..add(const LoadRoutines()),
        ),
        BlocProvider(
          create:
              (context) =>
                                     RoutineCategoriesBloc(RepositoryProvider.of<SupabaseService>(context))
                     ..add(const LoadRoutineCategories()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Roomah',
        routerConfig: router,
        builder: (context, child) {
          return NeumorphicTheme(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            child: child!,
          );
        },
      ),
    );
  }
}
