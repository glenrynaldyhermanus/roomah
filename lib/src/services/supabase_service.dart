import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> updateInventoryItem({
    required String itemId,
    required String householdId,
    required Map<String, dynamic> updateData,
  }) async {
    await _client
        .from('inventory_items')
        .update(updateData)
        .eq('id', itemId)
        .eq('household_id', householdId);
    _log('updateInventoryItem', {'itemId': itemId, 'updateData': updateData});
  }

  /// Uploads image bytes to [AppConstants.inventoryItemsStorageBucket]; returns public URL for `inventory_items.image_url`.
  Future<String> uploadInventoryItemImage({
    required String householdId,
    required Uint8List bytes,
    required String contentType,
    required String fileExtension,
  }) async {
    final user = currentUser;
    if (user == null) throw const AuthException('User not logged in');

    final safeExt = fileExtension.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    final ext = safeExt.isEmpty ? 'jpg' : safeExt;
    final path = '$householdId/${user.id}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _client.storage.from(AppConstants.inventoryItemsStorageBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
          ),
        );

    final url = _client.storage.from(AppConstants.inventoryItemsStorageBucket).getPublicUrl(path);
    _log('uploadInventoryItemImage', path);
    return url;
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

  /// All inventory rows for a household (e.g. guide checklist name matching).
  Future<List<Map<String, dynamic>>> getInventoryItemsForHousehold(String householdId) async {
    final response = await _client
        .from('inventory_items')
        .select()
        .eq('household_id', householdId)
        .order('name');
    _log('getInventoryItemsForHousehold', response.length);
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
        .select('*, items!inner(*)')
        .eq('items.household_id', householdId)
        .order('created_at', ascending: false);
    _log('getShoppingList', response);
    final rows = List<Map<String, dynamic>>.from(response);
    return rows.map((row) {
      final flat = Map<String, dynamic>.from(row);
      final nestedItem = flat.remove('items');
      if (nestedItem is Map<String, dynamic>) {
        final itemName = nestedItem['name'];
        if (itemName != null) flat['name'] = itemName;
      }
      return flat;
    }).toList();
  }

  Future<void> addShoppingItem(String name, String householdId) async {
    final user = currentUser;
    if (user == null) return;

    final catalogItem = await _client
        .from('items')
        .insert({
          'name': name,
          'household_id': householdId,
          'created_by': user.id,
        })
        .select()
        .single();

    await _client.from('shopping_list_items').insert({
      'item_id': catalogItem['id'],
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

  /// Adds a line to the shopping list using an existing catalog [itemId] (no new `items` row).
  Future<void> addCatalogItemToShoppingList(String catalogItemId) async {
    final user = currentUser;
    if (user == null) return;

    final dup = await _client
        .from('shopping_list_items')
        .select('id')
        .eq('item_id', catalogItemId)
        .eq('is_checked', false)
        .limit(1)
        .maybeSingle();
    if (dup != null) {
      _log('addCatalogItemToShoppingList', 'Skip duplicate unchecked for $catalogItemId');
      return;
    }

    await _client.from('shopping_list_items').insert({
      'item_id': catalogItemId,
      'created_by': user.id,
      'is_checked': false,
    });
    _log('addCatalogItemToShoppingList', catalogItemId);
  }

  // Catalog items (shopping / guide materials)
  Future<List<Map<String, dynamic>>> getCatalogItems(String householdId) async {
    final response = await _client
        .from('items')
        .select()
        .eq('household_id', householdId)
        .order('name');
    _log('getCatalogItems', response.length);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createCatalogItem({
    required String name,
    required String householdId,
  }) async {
    final user = currentUser;
    if (user == null) throw const AuthException('User not logged in');

    final row = await _client.from('items').insert({
      'name': name.trim(),
      'household_id': householdId,
      'created_by': user.id,
    }).select().single();
    _log('createCatalogItem', row['id']);
    return row;
  }

  // Guides (How To / SOP)
  Future<List<Map<String, dynamic>>> getGuides(String householdId) async {
    final response = await _client
        .from('guides')
        .select()
        .eq('household_id', householdId)
        .order('title');
    _log('getGuides', response.length);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getGuideById(String guideId, String householdId) async {
    final row = await _client
        .from('guides')
        .select('*, guide_items(*, items(*))')
        .eq('id', guideId)
        .eq('household_id', householdId)
        .maybeSingle();
    _log('getGuideById', row != null);
    return row == null ? null : Map<String, dynamic>.from(row);
  }

  Future<Map<String, dynamic>> createGuide({
    required String householdId,
    required String title,
    String? description,
    List<dynamic>? stepsJson,
  }) async {
    final user = currentUser;
    if (user == null) throw const AuthException('User not logged in');

    final row = await _client.from('guides').insert({
      'household_id': householdId,
      'title': title.trim(),
      if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
      if (stepsJson != null && stepsJson.isNotEmpty) 'steps': stepsJson,
      'created_by': user.id,
    }).select().single();
    _log('createGuide', row['id']);
    return row;
  }

  Future<void> updateGuide({
    required String guideId,
    required String householdId,
    required String title,
    String? description,
    List<dynamic>? stepsJson,
  }) async {
    final map = <String, dynamic>{
      'title': title.trim(),
      'steps': stepsJson,
    };
    if (description != null) {
      final t = description.trim();
      map['description'] = t.isEmpty ? null : t;
    }

    await _client.from('guides').update(map).eq('id', guideId).eq('household_id', householdId);
    _log('updateGuide', guideId);
  }

  Future<void> deleteGuide(String guideId, String householdId) async {
    await _client.from('guides').delete().eq('id', guideId).eq('household_id', householdId);
    _log('deleteGuide', guideId);
  }

  Future<void> replaceGuideItems({
    required String guideId,
    required List<Map<String, dynamic>> rows,
  }) async {
    await _client.from('guide_items').delete().eq('guide_id', guideId);
    if (rows.isEmpty) return;
    await _client.from('guide_items').insert(rows);
    _log('replaceGuideItems', '${rows.length} rows for $guideId');
  }

  /// [forDate]: calendar date used for `next_due_date` comparison (yyyy-MM-dd).
  Future<List<Map<String, dynamic>>> getRoutinesDueForHousehold(
    String householdId, {
    DateTime? forDate,
  }) async {
    final d = forDate ?? DateTime.now();
    final dateStr =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final response = await _client
        .from('routines')
        .select('*, guides(*)')
        .eq('household_id', householdId)
        .eq('is_active', true)
        .lte('next_due_date', dateStr)
        .isFilter('deleted_at', null)
        .order('next_due_date');
    _log('getRoutinesDueForHousehold', response.length);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getRoutinesForHousehold(String householdId) async {
    final response = await _client
        .from('routines')
        .select('*, guides(*)')
        .eq('household_id', householdId)
        .isFilter('deleted_at', null)
        .order('title');
    _log('getRoutinesForHousehold', response.length);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateRoutineGuideId({
    required String routineId,
    required String householdId,
    String? guideId,
  }) async {
    await _client.from('routines').update({
      'guide_id': guideId,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', routineId).eq('household_id', householdId);
    _log('updateRoutineGuideId', '$routineId -> $guideId');
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

  /// Opens WhatsApp (`wa.me`) from [whatsappNumber] or a http(s) URL from [contactUrl].
  static Future<bool> openStoreContact({
    String? whatsappNumber,
    String? contactUrl,
  }) async {
    final digits = (whatsappNumber ?? '').replaceAll(RegExp(r'\D'), '');
    Uri? uri;
    if (digits.isNotEmpty) {
      uri = Uri.parse('https://wa.me/$digits');
    } else {
      final raw = (contactUrl ?? '').trim();
      if (raw.isEmpty) return false;
      final withScheme =
          RegExp(r'^https?://', caseSensitive: false).hasMatch(raw)
              ? raw
              : 'https://$raw';
      uri = Uri.tryParse(withScheme);
    }
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<int> getMyTotalPoints(String householdId) async {
    final user = currentUser;
    if (user == null) return 0;

    final row = await _client
        .from('household_members')
        .select('total_points')
        .eq('household_id', householdId)
        .eq('user_id', user.id)
        .maybeSingle();

    final p = row?['total_points'];
    if (p is int) return p;
    if (p is num) return p.toInt();
    return 0;
  }

  Future<List<Map<String, dynamic>>> getStores(String householdId) async {
    final response = await _client
        .from('stores')
        .select()
        .eq('household_id', householdId)
        .order('name');
    _log('getStores', response);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createStore({
    required String name,
    required String householdId,
    String? whatsappNumber,
    String? contactUrl,
  }) async {
    final user = currentUser;
    if (user == null) throw const AuthException('User not logged in');

    final insert = <String, dynamic>{
      'name': name,
      'household_id': householdId,
      'created_by': user.id,
    };
    final w = whatsappNumber?.trim();
    final c = contactUrl?.trim();
    if (w != null && w.isNotEmpty) insert['whatsapp_number'] = w;
    if (c != null && c.isNotEmpty) insert['contact_url'] = c;

    final row = await _client.from('stores').insert(insert).select().single();
    _log('createStore', row);
    return row;
  }

  Future<void> updateStore({
    required String storeId,
    required String name,
    String? whatsappNumber,
    String? contactUrl,
  }) async {
    final w = whatsappNumber?.trim();
    final c = contactUrl?.trim();
    await _client.from('stores').update({
      'name': name,
      'whatsapp_number': (w == null || w.isEmpty) ? null : w,
      'contact_url': (c == null || c.isEmpty) ? null : c,
    }).eq('id', storeId);
    _log('updateStore', storeId);
  }

  Future<void> deleteStore(String storeId) async {
    await _client.from('stores').delete().eq('id', storeId);
    _log('deleteStore', storeId);
  }

  int _noteSortMillis(Map<String, dynamic> n) {
    final u = n['updated_at'];
    if (u != null) {
      return DateTime.parse(u as String).millisecondsSinceEpoch;
    }
    final c = n['created_at'];
    if (c != null) {
      return DateTime.parse(c as String).millisecondsSinceEpoch;
    }
    return 0;
  }

  Future<List<Map<String, dynamic>>> getNotes(String householdId) async {
    final response = await _client
        .from('notes')
        .select()
        .eq('household_id', householdId);
    final list = List<Map<String, dynamic>>.from(response);
    list.sort((a, b) {
      final ap = a['is_pinned'] == true;
      final bp = b['is_pinned'] == true;
      if (ap != bp) {
        if (ap) return -1;
        return 1;
      }
      return _noteSortMillis(b).compareTo(_noteSortMillis(a));
    });
    _log('getNotes', list.length);
    return list;
  }

  Future<Map<String, dynamic>> createNote({
    required String householdId,
    required String content,
    String? title,
    String? color,
    bool isPinned = false,
  }) async {
    final user = currentUser;
    if (user == null) throw const AuthException('User not logged in');

    final t = title?.trim();
    final row = await _client.from('notes').insert({
      'household_id': householdId,
      'content': content,
      if (t != null && t.isNotEmpty) 'title': t,
      'color': color ?? '#E23661',
      'is_pinned': isPinned,
      'created_by': user.id,
    }).select().single();
    _log('createNote', row['id']);
    return row;
  }

  Future<void> updateNote({
    required String noteId,
    String? title,
    String? content,
    String? color,
    bool? isPinned,
  }) async {
    final map = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (title != null) {
      final s = title.trim();
      map['title'] = s.isEmpty ? null : s;
    }
    if (content != null) map['content'] = content;
    if (color != null) map['color'] = color;
    if (isPinned != null) map['is_pinned'] = isPinned;
    await _client.from('notes').update(map).eq('id', noteId);
    _log('updateNote', noteId);
  }

  Future<void> deleteNote(String noteId) async {
    await _client.from('notes').delete().eq('id', noteId);
    _log('deleteNote', noteId);
  }

  Future<List<Map<String, dynamic>>> getRecipes(String householdId) async {
    final response = await _client
        .from('recipes')
        .select()
        .eq('household_id', householdId)
        .order('title');
    final list = List<Map<String, dynamic>>.from(response);
    _log('getRecipes', list.length);
    return list;
  }

  Future<Map<String, dynamic>> createRecipe({
    required String householdId,
    required String title,
    String? description,
    String? instructions,
    int? prepTimeMinutes,
  }) async {
    final t = title.trim();
    if (t.isEmpty) throw ArgumentError('title required');

    final row = await _client.from('recipes').insert({
      'household_id': householdId,
      'title': t,
      if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
      if (instructions != null && instructions.trim().isNotEmpty) 'instructions': instructions.trim(),
      if (prepTimeMinutes != null) 'prep_time_minutes': prepTimeMinutes,
    }).select().single();
    _log('createRecipe', row['id']);
    return row;
  }

  Future<void> updateRecipe({
    required String recipeId,
    required String householdId,
    required String title,
    String? description,
    String? instructions,
    int? prepTimeMinutes,
  }) async {
    final t = title.trim();
    if (t.isEmpty) throw ArgumentError('title required');

    final map = <String, dynamic>{
      'title': t,
      'description':
          description == null || description.trim().isEmpty ? null : description.trim(),
      'instructions':
          instructions == null || instructions.trim().isEmpty ? null : instructions.trim(),
      'prep_time_minutes': prepTimeMinutes,
    };
    await _client
        .from('recipes')
        .update(map)
        .eq('id', recipeId)
        .eq('household_id', householdId);
    _log('updateRecipe', recipeId);
  }
}
