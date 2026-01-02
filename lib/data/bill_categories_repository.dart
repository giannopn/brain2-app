import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brain2/models/bill_category.dart';

class BillCategoriesRepository {
  BillCategoriesRepository._internal() {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedOut) {
        clearCache();
      }
    });
  }

  static final BillCategoriesRepository instance =
      BillCategoriesRepository._internal();

  List<BillCategory>? _cachedCategories;

  List<BillCategory>? get cachedCategories => _cachedCategories;

  void setCache(List<BillCategory> categories) {
    _cachedCategories = categories;
  }

  Future<List<BillCategory>> fetchBillCategories({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedCategories != null) {
      return _cachedCategories!;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      clearCache();
      return [];
    }

    final response = await Supabase.instance.client
        .from('bill_categories')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    final categories = (response as List<dynamic>)
        .map((item) => BillCategory.fromMap(item as Map<String, dynamic>))
        .toList();

    _cachedCategories = categories;
    return categories;
  }

  Future<BillCategory> createBillCategory({
    required String title,
    String? imageUrl,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to create a category');
    }

    final response = await Supabase.instance.client
        .from('bill_categories')
        .insert({
          'user_id': user.id,
          'title': title,
          if (imageUrl != null) 'image_url': imageUrl,
        })
        .select()
        .single();

    final newCategory = BillCategory.fromMap(response);

    // Add to cache
    if (_cachedCategories != null) {
      _cachedCategories = [newCategory, ..._cachedCategories!];
    }

    return newCategory;
  }

  Future<BillCategory> updateBillCategory({
    required String id,
    String? title,
    String? imageUrl,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to update a category');
    }

    final updateData = <String, dynamic>{};
    if (title != null) updateData['title'] = title;
    if (imageUrl != null) updateData['image_url'] = imageUrl;

    if (updateData.isEmpty) {
      throw Exception('No fields to update');
    }

    final response = await Supabase.instance.client
        .from('bill_categories')
        .update(updateData)
        .eq('id', id)
        .eq('user_id', user.id)
        .select()
        .single();

    final updatedCategory = BillCategory.fromMap(response);

    // Update cache
    if (_cachedCategories != null) {
      _cachedCategories = _cachedCategories!.map((cat) {
        return cat.id == id ? updatedCategory : cat;
      }).toList();
    }

    return updatedCategory;
  }

  Future<void> deleteBillCategory(String id) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to delete a category');
    }

    await Supabase.instance.client
        .from('bill_categories')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id);

    // Remove from cache
    if (_cachedCategories != null) {
      _cachedCategories = _cachedCategories!
          .where((cat) => cat.id != id)
          .toList();
    }
  }

  void clearCache() {
    _cachedCategories = null;
  }
}
