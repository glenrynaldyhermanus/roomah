import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:myapp/app/blocs/calendar_data/calendar_data_bloc.dart';
import 'package:myapp/app/blocs/finance/finance_bloc.dart';
import 'package:myapp/app/blocs/todo/todo_bloc.dart';
import 'package:myapp/app/routes/app_router.dart';
import 'package:myapp/app/themes/app_theme.dart';
import 'package:myapp/app/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TodoBloc()),
        BlocProvider(create: (context) => FinanceBloc()),
        BlocProvider(create: (context) => CalendarDataBloc()),
      ],
      child: NeumorphicTheme(
        themeMode: ThemeMode.light,
        theme: AppTheme.themeData,
        child: Builder(
          builder: (context) => MaterialApp.router(
            title: 'Roomah',
            themeMode: ThemeMode.light,
            theme: ThemeData(
              colorScheme: ColorScheme.light(
                primary: AppTheme.primaryColor,
                secondary: AppTheme.accentColor,
                onPrimary: AppTheme.textColor,
                onSecondary: AppTheme.textColor,
              ),
              scaffoldBackgroundColor: AppTheme.primaryColor,
              textTheme: Theme.of(context).textTheme.apply(
                    bodyColor: AppTheme.textColor,
                    displayColor: AppTheme.textColor,
                  ),
              appBarTheme: AppBarTheme(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.textColor,
                elevation: 0,
              ),
            ),
            routerConfig: AppRouter.router,
          ),
        ),
      ),
    );
  }
}
