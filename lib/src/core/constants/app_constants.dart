class AppConstants {
  // TODO: Replace with actual Supabase URL and Anon Key
  static const String supabaseUrl = 'https://fcqehsciylskujjtqvxw.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZjcWVoc2NpeWxza3VqanRxdnh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI4MzUyNjAsImV4cCI6MjA2ODQxMTI2MH0.5vCzfyqIwTeQyBYVkHTTJVK0ObymT4YqvNu9L_XX7vY';

  /// Supabase Storage bucket for inventory item photos. Create as public read in dashboard if using [getPublicUrl].
  static const String inventoryItemsStorageBucket = 'inventory-items';
}
