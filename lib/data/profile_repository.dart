import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:brain2/models/profile.dart';

class ProfileRepository {
  ProfileRepository._internal() {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedOut) {
        clearCache();
      }
    });
  }

  static final ProfileRepository instance = ProfileRepository._internal();

  Profile? _cachedProfile;

  Profile? get cachedProfile => _cachedProfile;

  void setCache(Profile profile) {
    _cachedProfile = profile;
  }

  Future<Profile?> fetchProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedProfile != null) {
      return _cachedProfile;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      clearCache();
      return null;
    }

    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    final profile = Profile.fromMap(response);
    _cachedProfile = profile;
    return profile;
  }

  Future<Profile?> updateDisplayName(String newName) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final response = await Supabase.instance.client
        .from('profiles')
        .update({'display_name': newName})
        .eq('id', user.id)
        .select()
        .single();

    final updated = Profile.fromMap(response);
    _cachedProfile = updated;
    return updated;
  }

  void clearCache() {
    _cachedProfile = null;
  }
}
