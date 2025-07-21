import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/app/blocs/calendar_data/calendar_data_bloc.dart';
import 'package:myapp/app/blocs/finance/finance_bloc.dart';
import 'package:myapp/app/blocs/todo/todo_bloc.dart';
import 'package:myapp/app/routes/app_router.dart';
import 'package:myapp/app/services/supabase_service.dart';
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
                ..add(FetchFinances()),
        )
      ],
      child: MaterialApp.router(
        title: 'Roomah',
        routerConfig: router,
        builder: (context, child) {
                      return Theme(
              data: ThemeData(
                primarySwatch: Colors.blue,
                scaffoldBackgroundColor: const Color(0xFFE0E5EC),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
