import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../src/core/theme/app_colors.dart';
import '../../../src/core/theme/app_text_styles.dart';
import '../../../src/shared/glass_container.dart';
import '../../../src/shared/custom_text_field.dart';
import '../../../src/services/supabase_service.dart';
import '../register/register_page.dart';
import '../../dashboard/main_dashboard.dart';
import '../../family/create_family/create_family_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        throw const AuthException('Please enter both email and password.');
      }

      print('Login: Attempting sign in for $email');
      await SupabaseService().signIn(email, password);
      print('Login: Sign in successful');
      
      // Check if user has a household
      print('Login: Checking household');
      final householdId = await SupabaseService().getCurrentHouseholdId();
      print('Login: Household check complete. ID: $householdId');

      if (mounted) {
        if (householdId != null) {
          print('Login: Navigating to Dashboard');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainDashboard()),
          );
        } else {
          print('Login: Navigating to CreateFamily');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CreateFamilyPage()),
          );
        }
      }
    } catch (e) {
      print('Login Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Failed: ${e is AuthException ? e.message : e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryPink.withOpacity(0.4),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.primaryPink,
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentPink.withOpacity(0.3),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.accentPink,
                    blurRadius: 80,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ROOMAH",
                    style: AppTextStyles.headerLarge.copyWith(
                      color: AppColors.primaryPink,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 40),
                  GlassContainer(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Welcome Back",
                          style: AppTextStyles.headerMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          label: "Email",
                          hint: "hello@example.com",
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: "Password",
                          hint: "••••••••",
                          obscureText: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading 
                              ? const SizedBox(
                                  height: 20, 
                                  width: 20, 
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                ) 
                              : const Text("LOGIN"),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterPage()),
                            );
                          },
                          child: Text(
                            "Don't have an account? Register",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accentPink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
