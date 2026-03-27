import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../src/core/theme/app_colors.dart';
import '../../src/services/supabase_service.dart';
import '../auth/login/login_page.dart';
import '../dashboard/main_dashboard.dart';
import '../family/create_family/create_family_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Add a small delay for better UX (so the splash doesn't flash too fast)
    await Future.delayed(const Duration(seconds: 2));

    try {
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session == null) {
        _navigateToLogin();
        return;
      }

      // User is logged in, check for household
      final householdId = await SupabaseService().getCurrentHouseholdId();

      if (mounted) {
        if (householdId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CreateFamilyPage()),
          );
        }
      }
    } catch (e) {
      // If any error occurs, fallback to login
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple Logo Placeholder
            Icon(Icons.home_rounded, size: 80, color: AppColors.primaryPink),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.primaryPink),
          ],
        ),
      ),
    );
  }
}
