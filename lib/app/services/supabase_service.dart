
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://fcqehsciylskujjtqvxw.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZjcWVoc2NpeWxza3VqanRxdnh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI4MzUyNjAsImV4cCI6MjA2ODQxMTI2MH0.5vCzfyqIwTeQyBYVkHTTJVK0ObymT4YqvNu9L_XX7vY',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
