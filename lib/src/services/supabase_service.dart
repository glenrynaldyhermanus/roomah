import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  
  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  void _log(String operation, dynamic data) {
    // Using print for simplicity to show in debug console
    print('Supabase Log [$operation]: $data');
  }

  // Auth Methods
  Future<AuthResponse> signUp(String email, String password, {Map<String, dynamic>? data}) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Future<String?> getCurrentHouseholdId() async {
    final user = currentUser;
    if (user == null) return null;

    _log('getCurrentHouseholdId', 'Checking for user ${user.id}');

    final response = await _client
        .from('household_members')
        .select('household_id')
        .eq('user_id', user.id)
        .limit(1)
        .maybeSingle();

    _log('getCurrentHouseholdId', response);
    return response?['household_id'] as String?;
  }

  // Household Methods
  Future<Map<String, dynamic>> createHousehold(String name) async {
    final user = currentUser;
    if (user == null) throw const AuthException('User not logged in');

    // 1. Create Household
    final householdData = await _client
        .from('households')
        .insert({'name': name, 'created_by': user.id})
        .select()
        .single();
    
    _log('createHousehold', householdData);

    final householdId = householdData['id'];

    // 2. Add Creator as Member (Admin)
    await _client.from('household_members').insert({
      'household_id': householdId,
      'user_id': user.id,
      'role': 'admin',
    });

    // 3. Create Default Categories
    await createDefaultCategories(householdId);

    return householdData;
  }

  Future<void> createDefaultCategories(String householdId) async {
    final categories = [
      {'name': 'Kitchen', 'icon': 'kitchen', 'household_id': householdId},
      {'name': 'Toilet', 'icon': 'toilet', 'household_id': householdId},
      {'name': 'Bedroom', 'icon': 'bedroom', 'household_id': householdId},
      {'name': 'Living Room', 'icon': 'living_room', 'household_id': householdId},
      {'name': 'Cleaning', 'icon': 'cleaning', 'household_id': householdId},
      {'name': 'Others', 'icon': 'others', 'household_id': householdId},
    ];

    await _client.from('inventory_categories').insert(categories);
  }

  Future<void> inviteMember(String email, String householdId) async {
    // This is a simplified invite flow. In a real app, you'd send an email or create an invite link.
    // Here we'll just check if the user exists and add them directly for simplicity, 
    // or throw an error if we can't find them.
    
    // Note: This requires a way to lookup users by email which might be restricted.
    // For this MVP, let's assume we just insert a pending invite or similar if we had that table,
    // but since we don't, we will just try to find the user ID from a hypothetical 'profiles' or 'users' table 
    // if it existed and was public. 
    
    // Since we only have auth.users which isn't directly queryable for other users usually:
    // We will just simulate a success for the UI flow or implement a basic check if we added a public profiles table.
    // The schema has a public.users table! We can use that.
    
    final user = await _client
        .from('users')
        .select('id')
        .eq('email', email)
        .maybeSingle();

    if (user == null) {
      throw const PostgrestException(message: 'User not found with this email.');
    }

    await _client.from('household_members').insert({
      'household_id': householdId,
      'user_id': user['id'],
      'role': 'member',
    });
    _log('inviteMember', 'Invited $email to household $householdId');
  }

  // Inventory Methods
  Future<List<Map<String, dynamic>>> getInventoryCategories(String householdId) async {
    final response = await _client
        .from('inventory_categories')
        .select()
        .eq('household_id', householdId)
        .order('name');
    _log('getInventoryCategories', response);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getInventoryItems(String householdId, String categoryId) async {
    final response = await _client
        .from('inventory_items')
        .select()
        .eq('household_id', householdId)
        .eq('category_id', categoryId)
        .order('created_at', ascending: false);
    _log('getInventoryItems', response);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addCategory(String name, String icon, String householdId) async {
    await _client.from('inventory_categories').insert({
      'name': name,
      'icon': icon,
      'household_id': householdId,
    });
    _log('addCategory', 'Added category $name');
  }

  Future<void> addInventoryItem(Map<String, dynamic> itemData) async {
    await _client.from('inventory_items').insert(itemData);
    _log('addInventoryItem', itemData);
  }

  Future<List<Map<String, dynamic>>> getLowStockItems(String householdId) async {
    final response = await _client
        .from('inventory_items')
        .select()
        .eq('household_id', householdId)
        .or('status.eq.low_stock,status.eq.out_of_stock')
        .order('created_at', ascending: false);
    _log('getLowStockItems', response);
    return List<Map<String, dynamic>>.from(response);
  }

  // Event Methods
  Future<List<Map<String, dynamic>>> getEvents(String householdId) async {
    final response = await _client
        .from('events')
        .select()
        .eq('household_id', householdId)
        .order('event_date', ascending: true);
    _log('getEvents', response);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getUpcomingEvents(String householdId) async {
    final now = DateTime.now();
    final response = await _client
        .from('events')
        .select()
        .eq('household_id', householdId)
        .gte('event_date', now.toIso8601String())
        .order('event_date', ascending: true)
        .limit(5);
    _log('getUpcomingEvents', response);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createEvent(Map<String, dynamic> eventData) async {
    await _client.from('events').insert(eventData);
    _log('createEvent', eventData);
  }

  Future<void> deleteEvent(String eventId) async {
    await _client.from('events').delete().eq('id', eventId);
    _log('deleteEvent', 'Deleted event $eventId');
  }

  // Shopping List Methods
  Future<List<Map<String, dynamic>>> getShoppingList(String householdId) async {
    final response = await _client
        .from('shopping_list_items')
        .select()
        .eq('household_id', householdId)
        .order('created_at', ascending: false);
    _log('getShoppingList', response);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addShoppingItem(String name, String householdId) async {
    final user = currentUser;
    if (user == null) return;
    
    await _client.from('shopping_list_items').insert({
      'name': name,
      'household_id': householdId,
      'created_by': user.id,
      'is_checked': false,
    });
    _log('addShoppingItem', 'Added item $name');
  }

  Future<void> toggleShoppingItem(String itemId, bool isChecked) async {
    await _client.from('shopping_list_items').update({'is_checked': isChecked}).eq('id', itemId);
    _log('toggleShoppingItem', 'Toggled item $itemId to $isChecked');
  }

  Future<void> deleteShoppingItem(String itemId) async {
    await _client.from('shopping_list_items').delete().eq('id', itemId);
    _log('deleteShoppingItem', 'Deleted item $itemId');
  }

  // Todo Methods
  Future<List<Map<String, dynamic>>> getTodos() async {
    final user = currentUser;
    if (user == null) return [];

    final response = await _client
        .from('todos')
        .select()
        .eq('created_by', user.id)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);
    _log('getTodos', response);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getTodayTodos() async {
    final user = currentUser;
    if (user == null) return [];

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _client
        .from('todos')
        .select()
        .eq('created_by', user.id)
        .isFilter('deleted_at', null)
        .gte('created_at', startOfDay.toIso8601String())
        .lt('created_at', endOfDay.toIso8601String())
        .order('created_at', ascending: false);
    _log('getTodayTodos', response);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> toggleTodo(String todoId, bool isCompleted) async {
    final user = currentUser;
    if (user == null) return;

    await _client.from('todos').update({
      'is_completed': isCompleted,
      'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
      'updated_by': user.id,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', todoId);
    _log('toggleTodo', 'Toggled todo $todoId to $isCompleted');
  }

  Future<void> createTodo(String title, {String? description}) async {
    final user = currentUser;
    if (user == null) return;

    await _client.from('todos').insert({
      'title': title,
      'description': description,
      'created_by': user.id,
      'is_completed': false,
    });
    _log('createTodo', 'Created todo $title');
  }
}
