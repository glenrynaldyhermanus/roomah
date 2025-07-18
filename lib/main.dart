import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:myapp/app/blocs/calendar_data/calendar_data_bloc.dart';
import 'package:myapp/app/blocs/finance/finance_bloc.dart';
import 'package:myapp/app/blocs/todo/todo_bloc.dart';
import 'package:myapp/app/routes/app_router.dart';
import 'package:myapp/app/services/supabase_service.dart';
import 'package:myapp/app/themes/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://brkfirwvesitxmskmxpdc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJya2Zpcnd2ZXNpdHhtc2tteHBkYyIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNzE2MzE0NjExLCJleHAiOjIwMzE4OTA2MTF9.IuD-1x2wqw7JNfOETb2G2mhPjO0da_MNe0syCazF2sU',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (context) => SupabaseService(),
        ),
        BlocProvider(
          create: (context) =>
              TodoBloc(RepositoryProvider.of<SupabaseService>(context))
                ..add(FetchTodos()),
        ),
        BlocProvider(
          create: (context) => CalendarDataBloc(
              RepositoryProvider.of<SupabaseService>(context)),
        ),
        BlocProvider(
          create: (context) =>
              FinanceBloc(RepositoryProvider.of<SupabaseService>(context))
                ..add(FetchTransactions()),
        )
      ],
      child: MaterialApp.router(
        title: 'My App',
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
