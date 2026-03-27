import 'package:flutter/material.dart';
import 'src/core/theme/app_theme.dart';
import 'app/auth/login/login_page.dart';
import 'app/splash/splash_page.dart';

import 'src/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const RoomahApp());
}

class RoomahApp extends StatelessWidget {
  const RoomahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roomah',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}
